#############################################
# Store DB Secrets in SSM Parameter Store
#############################################

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project_name}/${var.environment}/DB_NAME"
  type  = "String"
  value = var.db_name

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.project_name}/${var.environment}/DB_USERNAME"
  type  = "String"
  value = var.db_username

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/${var.environment}/DB_PASSWORD"
  type  = "SecureString"
  value = var.db_password

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.project_name}/${var.environment}/DB_HOST"
  type  = "String"
  value = var.rds_endpoint

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
