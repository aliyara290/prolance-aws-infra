module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment

  vpc_cidr = "10.0.0.0/16"

  public_subnets = {
    pb_az_a = {
      cidr_block = "10.0.1.0/24"
      az         = "eu-west-3a"
    }

    pb_az_b = {
      cidr_block = "10.0.2.0/24"
      az         = "eu-west-3b"
    }
  }

  private_application_subnets = {
    app_az_a = {
      cidr_block = "10.0.11.0/24"
      az         = "eu-west-3a"
    }

    app_az_b = {
      cidr_block = "10.0.12.0/24"
      az         = "eu-west-3b"
    }
  }

  private_database_subnets = {
    db_az_a = {
      cidr_block = "10.0.21.0/24"
      az         = "eu-west-3a"
    }

    db_az_b = {
      cidr_block = "10.0.22.0/24"
      az         = "eu-west-3b"
    }
  }
}

locals {
  db_names = {
    "keycloak"             = "keycloak_db"
    "tenant-service"       = "tenant_db"
    "project-service"      = "project_db"
    "tasks-service"        = "task_db"
    "notification-service" = "notification_db"
    "crm-service"          = "crm_db"
    "billing-service"      = "billing_db"
    "attachment-service"   = "attachments_db"
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

  image_tag_mutability = "MUTABLE"

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

# Cloud Map for internal communication between microsrvices and eurela/config server (because eureka and config server does not register in eureka server discovery)

module "cloud_map" {
  source = "../../modules/cloud-map"

  vpc_id = module.vpc.vpc_id

  namespace_name = "prolance.local"

  service_discovery_services = {
    "eureka-server" = {
      ttl            = 10,
      type           = "A"
      routing_policy = "MULTIVALUE"
    },
    "config-server" = {
      ttl            = 10,
      type           = "A"
      routing_policy = "MULTIVALUE"
    },
    "keycloak" = {
      ttl            = 10,
      type           = "A"
      routing_policy = "MULTIVALUE"
    },
  }

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
    alb_traffic_8080 = {
      description                  = "Allow traffic from ALB on port 8080"
      from_port                    = 8080
      to_port                      = 8080
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb_sg.id
    }
    alb_traffic_8761 = {
      description                  = "Allow traffic from ALB on port 8761"
      from_port                    = 8761
      to_port                      = 8761
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb_sg.id
    }
  }

  egress_rules = {
    all_outbound = {
      description = "Allow all outbound traffic"
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
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_services_self" {
  security_group_id            = module.internal_services_sg.id
  referenced_security_group_id = module.internal_services_sg.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  description                  = "Allow internal microservices to communicate with each other"
}

module "rds_database_sg" {
  source      = "../../modules/security-groups"
  environment = var.environment

  sg_name        = "rds-database-sg"
  sg_description = "Security group for RDS databases"
  vpc_id         = module.vpc.vpc_id

  ingress_rules = {
    microservices-traffic = {
      description                  = "Allow all traffic from Microservices"
      from_port                    = 5432
      to_port                      = 5432
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.internal_services_sg.id
    }
  }

  egress_rules = {
    all_outbound = {
      description = "Allow all outbound traffic"
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
    keycloak = {
      port              = 8080
      health_check_path = "/"
    }
    eureka = {
      port              = 8761
      health_check_path = "/actuator/health"
    }
  }

  listeners = {
    http = {
      port             = 80
      protocol         = "HTTP"
      action_type      = "forward"
      target_group_key = "api-gw"
    }
  }

  listener_rules = {
    keycloak_rule = {
      listener_key     = "http"
      priority         = 10
      action_type      = "forward"
      target_group_key = "keycloak"
      path_patterns    = ["/keycloak/*", "/realms/*", "/resources/*", "/admin/*", "/js/*"]
    }
    eureka_rule = {
      listener_key     = "http"
      priority         = 20
      action_type      = "forward"
      target_group_key = "eureka"
      path_patterns    = ["/eureka/*", "/eureka-ui/*", "/eureka-ui"]
    }
    api_gw_rule = {
      listener_key     = "http"
      priority         = 30
      action_type      = "forward"
      target_group_key = "api-gw"
      path_patterns    = ["/api/*"]
    }
  }

  enable_deletion_protection = false
}


module "rds" {
  source = "../../modules/rds"

  environment = var.environment

  identifier = "prolance-${var.environment}-postgres"

  engine_version = "17"

  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100


  username = "prolance_admin"
  password = var.rds_password

  subnet_ids = module.vpc.private_db_subnet_ids

  security_group_ids = [
    module.rds_database_sg.id
  ]

  multi_az = false

  backup_retention_period = 7

  deletion_protection = false
  skip_final_snapshot = true
}


# ECS Services

module "ecs_service" {
  source = "../../modules/ecs-service"

  depends_on = [module.elb]

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
  container_definitions = {
    for c_key, c_val in each.value.container_definitions : c_key => {
      container_name        = c_val.container_name
      container_image       = c_val.container_image
      essential             = c_val.essential
      port_mappings         = c_val.port_mappings
      secrets_arn           = c_val.secrets_arn
      aws_log_group         = c_val.aws_log_group
      commands              = c_val.commands
      environment_variables = merge(
        c_val.environment_variables,
        each.key == "keycloak" ? {
          "KC_DB_URL"             = "jdbc:postgresql://${module.rds.endpoint}/${local.db_names[each.key]}"
          "KC_HOSTNAME_URL"       = "http://${module.elb.elb_dns_name}"
          "KC_HOSTNAME_ADMIN_URL" = "http://${module.elb.elb_dns_name}"
        } : (contains(keys(local.db_names), each.key) ? {
          "SPRING_DATASOURCE_URL" = "jdbc:postgresql://${module.rds.endpoint}/${local.db_names[each.key]}"
        } : {})
      )
    }
  }
  cpu           = each.value.cpu
  memory        = each.value.memory
  desired_count = each.value.desired_count

  service_registry_arn = try(module.cloud_map.discovery_service_arns[each.key], null)

  # Services exposed to ALB get both the api_gateway_sg (ALB traffic) and internal_services_sg (RDS & inter-service traffic)
  security_groups_ids = contains(["api-gateway", "keycloak", "eureka-server"], each.key) ? [module.api_gateway_sg.id, module.internal_services_sg.id] : [module.internal_services_sg.id]

  # Assign correct target group if the service is exposed via ALB
  target_group_arn = each.key == "api-gateway" ? module.elb.target_group_arns["api-gw"] : (
    each.key == "keycloak" ? module.elb.target_group_arns["keycloak"] : (
      each.key == "eureka-server" ? module.elb.target_group_arns["eureka"] : null
    )
  )

  log_retention_days = 30
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/prolance-db-init"
  retention_in_days = 3

  tags = merge(
    {
      Name = "/ecs/prolance-db-init"
    }
  )
}

resource "aws_ecs_task_definition" "db_init" {
  family                   = "prolance-db-init"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 256
  memory = 512

  execution_role_arn = "arn:aws:iam::973213516951:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name  = "db-init"
      image = "postgres:17"

      essential = true

      environment = [
        {
          name  = "PGHOST"
          value = module.rds.address
        },
        {
          name  = "PGPORT"
          value = "5432"
        },
        {
          name  = "PGUSER"
          value = "prolance_admin"
        },
        {
          name  = "PGPASSWORD"
          value = var.rds_password
        }
      ]


      command = [
        "sh",
        "-c",
        <<-EOT
    for db in keycloak_db tenant_db project_db task_db notification_db crm_db billing_db attachments_db; do
      if [ -z "$(psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db'")" ]; then
        echo "Creating database $db..."
        psql -d postgres -c "CREATE DATABASE $db;"
      else
        echo "Database $db already exists, skipping."
      fi
    done
    
    echo "=== Keycloak SSL Fix ==="
    echo "Before:"
    psql -d keycloak_db -c "SELECT id, name, ssl_required FROM realm;" 2>&1 || echo "realm table not found"
    echo "Disabling strict SSL for all Keycloak realms..."
    psql -d keycloak_db -c "UPDATE realm SET ssl_required = 'NONE';" 2>&1 || echo "Keycloak schema not ready yet, skipping SSL update."
    echo "After:"
    psql -d keycloak_db -c "SELECT id, name, ssl_required FROM realm;" 2>&1 || echo "realm table not found"
  EOT
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = "/ecs/prolance-db-init"
          "awslogs-region"        = "eu-west-3"
          "awslogs-stream-prefix" = "db-init"
        }
      }
    }
  ])
}