resource "aws_s3_bucket" "static_content" {
  bucket = "${var.project_name}-${var.environment}-static"

  # Enable versioning
  versioning {
    enabled = true
  }

  # Enable server-side encryption (SSE-S3)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # For SSE-S3
        
      }
    }
  }

  # Optional: block public access
  acl = "private"

  tags = {
    Name        = "${var.project_name}-${var.environment}-static-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}
