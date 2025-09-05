output "rds_endpoint" {
  description = "DNS hostname to connect to the RDS instance (without port)"
  value       = aws_db_instance.mysql.address
}

output "rds_instance_id" {
  description = "RDS instance identifier for CloudWatch metrics"
  value       = aws_db_instance.mysql.identifier
}



output "rds_storage_threshold" {
  value = aws_db_instance.mysql.allocated_storage
}
