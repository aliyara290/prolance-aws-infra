module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment

  vpc_cidr = "10.0.0.0/16"

  public_subnets = {
    az_a = {
      cidr_block = "10.0.1.0/24"
      az         = "eu-west-3a"
    }

    az_b = {
      cidr_block = "10.0.2.0/24"
      az         = "eu-west-3b"
    }
  }

  private_application_subnets = {
    az_a = {
      cidr_block = "10.0.11.0/24"
      az         = "eu-west-3a"
    }

    az_b = {
      cidr_block = "10.0.12.0/24"
      az         = "eu-west-3b"
    }
  }

  private_database_subnets = {
    az_a = {
      cidr_block = "10.0.21.0/24"
      az         = "eu-west-3a"
    }

    az_b = {
      cidr_block = "10.0.22.0/24"
      az         = "eu-west-3b"
    }
  }
}

# Elastic Container Registry (ECR)
module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment

  repositories = [
    "api-gateway",
    "tenant-service",
    "project-service",
    "tasks-service",
    "eureka-server",
    "config-server",
    "attachment-service",
    "billing-service",
    "crm-service",
    "notification-service"
  ]

  image_tag_mutability = "IMMUTABLE"

  scan_on_push = true

  encryption_type = "AES256"

  keep_image_count = 15
}

# ECS Cluster

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  environment = var.environment

  ecs_cluster_name = "prolance-dev-cluster"

  container_insights = true

}

# Security Groups

# ALB SG
module "alb_sg" {
  source      = "../../modules/security-groups"
  environment = var.environment

  sg_name        = "alb"
  sg_description = "Security group for the Application Load Balancer"
  vpc_id         = module.vpc.vpc_id

  ingress_rules = {
    http = {
      description = "Allow HTTP from internet"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      description = "Allow HTTPS from internet"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  egress_rules = {
    all_outbound = {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

# API Gateway SG, only accepts traffic from the ALB
module "api_gateway_sg" {
  source      = "../../modules/security-groups"
  environment = var.environment

  sg_name        = "api-gateway"
  sg_description = "Security group for the API Gateway ECS service"
  vpc_id         = module.vpc.vpc_id

  ingress_rules = {
    alb_traffic = {
      description                  = "Allow traffic from ALB on port 8080"
      from_port                    = 8080
      to_port                      = 8080
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb_sg.id
    }
  }

  egress_rules = {
    all_outbound = {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

# Internal Services SG, only accepts traffic from the API Gateway
module "internal_services_sg" {
  source      = "../../modules/security-groups"
  environment = var.environment

  sg_name        = "internal-services"
  sg_description = "Security group for internal ECS microservices"
  vpc_id         = module.vpc.vpc_id

  ingress_rules = {
    api_gateway_traffic = {
      description                  = "Allow all traffic from API Gateway"
      from_port                    = 0
      to_port                      = 65535
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.api_gateway_sg.id
    }
  }

  egress_rules = {
    all_outbound = {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}


# Application Load Balancer

module "elb" {
  source = "../../modules/elb"

  name        = "prolance-alb"
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.id]

  target_groups = {
    api-gw = {
      port              = 8080
      health_check_path = "/actuator/health"
    }
  }

  listeners = {
    http = {
      port                 = 80
      protocol             = "HTTP"
      action_type          = "redirect"
      redirect_port        = "443"
      redirect_protocol    = "HTTPS"
      redirect_status_code = "HTTP_301"
    }

    # Uncomment when an ACM certificate is available
    # https = {
    #   port             = 443
    #   protocol         = "HTTPS"
    #   certificate_arn  = var.certificate_arn
    #   action_type      = "forward"
    #   target_group_key = "api-gw"
    # }
  }

  enable_deletion_protection = false
}



# ECS Services

module "ecs_service" {
  source = "../../modules/ecs-service"

  for_each = var.ecs_services

  environment = var.environment
  cluster_arn = module.ecs_cluster.arn

  assign_public_ip                    = false
  platform_version                    = "LATEST"
  health_check_grace_period_seconds   = 100
  deployment_maximum_percent          = 200
  deployment_minimum_health_percent   = 100
  deployment_circuit_breaker_enabled  = true
  deployment_circuit_breaker_rollback = true
  subnet_ids                          = module.vpc.private_app_subnet_ids

  service_name          = each.value.service_name
  container_definitions = each.value.container_definitions

  cpu           = each.value.cpu
  memory        = each.value.memory
  desired_count = each.value.desired_count

  # api-gateway gets its own SG (reachable from ALB), all other services get the internal SG (reachable only from api-gateway)
  security_groups_ids = each.key == "api-gateway" ? [module.api_gateway_sg.id] : [module.internal_services_sg.id]

  # Only api-gateway is registered with the ALB target group, because it's the only service that ALB talk with, so no need for target group for other service!
  target_group_arn = each.key == "api-gateway" ? module.alb.target_group_arns["api-gw"] : null

  log_retention_days = 30
}

