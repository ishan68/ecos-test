############################################
# Security Group for Application EC2
############################################
resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for private EC2 application server"
  vpc_id      = aws_vpc.main.id

  # Allow SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow HTTPS
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
  }
}

############################################
# Application EC2 Instance (Private)
############################################
resource "aws_instance" "app" {
  ami                    = var.app_ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private1.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app.id]

    iam_instance_profile   = aws_iam_instance_profile.app_ec2_profile.name


  tags = {
    Name = "${var.project_name}-${var.environment}-app-server"
  }
}


############################################
# IAM Role for EC2
############################################
resource "aws_iam_role" "app_ec2_role" {
  name = "${var.project_name}-${var.environment}-app-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# IAM Policy for S3 (Least Privilege)
############################################
resource "aws_iam_policy" "app_s3_policy" {
  name        = "${var.project_name}-${var.environment}-app-s3-policy"
  description = "Allow EC2 app to access specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}


############################################
# IAM Policy for Secrets Manager (Least Privilege)
############################################
resource "aws_iam_policy" "app_secrets_policy" {
  name        = "${var.project_name}-${var.environment}-app-secrets-policy"
  description = "Allow EC2 app to read specific Secrets Manager secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.app_secret_arn
      }
    ]
  })
}

############################################
# Attach Policies to Role
############################################
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = aws_iam_policy.app_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "secrets_attach" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = aws_iam_policy.app_secrets_policy.arn
}

############################################
# Instance Profile (to attach to EC2)
############################################
resource "aws_iam_instance_profile" "app_ec2_profile" {
  name = "${var.project_name}-${var.environment}-app-ec2-profile"
  role = aws_iam_role.app_ec2_role.name
}
