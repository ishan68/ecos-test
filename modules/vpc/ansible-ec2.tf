############################################
# Security Group for Ansible EC2
############################################
resource "aws_security_group" "ansible" {
  name        = "${var.project_name}-${var.environment}-ansible-sg"
  description = "Security group for Ansible-managed EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["223.178.208.136/32"]   
  }

  ingress {
    description = "HTTP for testing app"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ansible-sg"
  }
}

############################################
# IAM Role for CloudWatch Agent
############################################
resource "aws_iam_role" "cw_agent_role" {
  name = "${var.project_name}-${var.environment}-cw-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# Attach CloudWatchAgentServerPolicy
############################################
resource "aws_iam_role_policy_attachment" "cw_agent_policy_attach" {
  role       = aws_iam_role.cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

############################################
# Instance Profile for EC2
############################################
resource "aws_iam_instance_profile" "cw_agent_profile" {
  name = "${var.project_name}-${var.environment}-cw-agent-profile"
  role = aws_iam_role.cw_agent_role.name
}

############################################
# EC2 Instance for Ansible deployment
############################################
resource "aws_instance" "ansible" {
  ami                    = var.ansible_ami_id      
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ansible.id]

  iam_instance_profile   = aws_iam_instance_profile.cw_agent_profile.name  # 🔹 Attach IAM profile here

  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ansible-instance"
  }
}
############################################
# Elastic IP for Ansible EC2
############################################
resource "aws_eip" "ansible" {
  

  tags = {
    Name = "${var.project_name}-${var.environment}-ansible-eip"
  }
}

############################################
# Associate Elastic IP with EC2 instance
############################################
resource "aws_eip_association" "ansible" {
  instance_id   = aws_instance.ansible.id
  allocation_id = aws_eip.ansible.id
}
