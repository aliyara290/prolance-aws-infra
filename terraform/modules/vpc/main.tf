resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Prolance-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Prolance-${var.environment}-igw"
  }
}


resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "Prolance-${var.environment}-public-${each.key}"
  }
}

resource "aws_subnet" "private_app_subnets" {
  for_each = var.private_application_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "Prolance-${var.environment}-private-${each.key}"
  }
}

resource "aws_subnet" "private_db_subnets" {
  for_each = var.private_database_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "Prolance-${var.environment}-private-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Prolance-${var.environment}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

resource "aws_nat_gateway" "this" {
  vpc_id            = aws_vpc.this.id
  availability_mode = "regional"
  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "Prolance-${var.environment}-regional-ngw"
  }
}

resource "aws_route_table" "private_app_subnets" {
  for_each = aws_subnet.private_app_subnets
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = "Prolance-${var.environment}-private-app-rt-${each.key}"
  }
}

resource "aws_route" "private_app_internet" {
  for_each               = aws_route_table.private_app_subnets
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private_app_subnets" {
  for_each       = aws_subnet.private_app_subnets
  route_table_id = aws_route_table.private_app_subnets[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route_table" "private_db_subnets" {
  for_each = aws_subnet.private_db_subnets
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = "Prolance-${var.environment}-private-db-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private_db_subnets" {
  for_each       = aws_subnet.private_db_subnets
  route_table_id = aws_route_table.private_db_subnets[each.key].id
  subnet_id      = each.value.id
}