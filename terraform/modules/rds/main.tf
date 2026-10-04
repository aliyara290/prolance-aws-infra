resource "aws_db_subnet_group" "this" {
  name = "${var.identifier}-subnet-group"

  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-subnet-group"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  storage_encrypted = true

  db_name  = var.database_name
  username = var.username
  password = var.password

  port = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids

  publicly_accessible = false

  multi_az = var.multi_az

  backup_retention_period = var.backup_retention_period

  deletion_protection = var.deletion_protection

  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "${var.identifier}-final-snapshot"

  auto_minor_version_upgrade = true

  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )
}