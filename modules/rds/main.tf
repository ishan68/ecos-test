############################################
# RDS Security Group
############################################
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Allow access to RDS from private subnet"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL from private subnet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

############################################
# RDS Subnet Group
############################################
resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.project_name}-${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-subnet-group"
  }
}

############################################
# RDS Instance
############################################
resource "aws_db_instance" "mysql" {
  identifier          = "${var.project_name}-${var.environment}-mysql"
  allocated_storage    = var.db_allocated_storage
  engine               = "mysql"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  port                 = 3306
  publicly_accessible  = false
  storage_type         = "gp3"
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  skip_final_snapshot    = true
  multi_az               = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql-rds"
  }
}
