resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_config_role_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


#############################################
# AWS Config Recorder
#############################################
resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.project_name}-${var.environment}-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

#############################################
# AWS Config Delivery Channel
#############################################
resource "aws_s3_bucket" "config_logs" {
  bucket = "${var.project_name}-${var.environment}-config-logs"

  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_config_delivery_channel" "channel" {
  name           = "${var.project_name}-${var.environment}-channel"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket
}

#############################################
# Start the Recorder
#############################################
resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
}
