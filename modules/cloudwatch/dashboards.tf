resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # EC2 CPU Utilization
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          title   = "EC2 CPU Utilization"
          region  = var.region
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.ansible_instance_id]
          ]
          period = 300
          stat   = "Average"
          yAxis = {
            left = {
              label = "CPU %"
              min   = 0
              max   = 100
            }
          }
        }
      },

      # EC2 Status Check
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          title   = "EC2 Status Check Failed"
          region  = var.region
          metrics = [
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", var.ansible_instance_id]
          ]
          period = 300
          stat   = "Maximum"
          yAxis = {
            left = {
              label = "StatusCheck"
              min   = 0
              max   = 1
            }
          }
        }
      },

      # RDS Free Storage Space (in GB for better readability)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          title   = "RDS Free Storage Space (GB)"
          region  = var.region
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_instance_id, { "stat": "Average" }]
          ]
          period = 300
          stat   = "Average"
          yAxis = {
            left = {
              label = "GB"
            }
          }
          # Convert bytes to GB
          annotations = {
            horizontal = [
              {
                label = "Low Storage Warning"
                value = 2147483648  # 2GB in bytes
              }
            ]
          }
        }
      },

      # RDS CPU Utilization
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          title   = "RDS CPU Utilization"
          region  = var.region
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id]
          ]
          period = 300
          stat   = "Average"
          yAxis = {
            left = {
              label = "CPU %"
              min   = 0
              max   = 100
            }
          }
        }
      },

      # RDS Database Connections
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          title   = "RDS Database Connections"
          region  = var.region
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_id]
          ]
          period = 300
          stat   = "Average"
          yAxis = {
            left = {
              label = "Connections"
              min   = 0
            }
          }
        }
      },

      # RDS Read/Write IOPS
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          title   = "RDS Read/Write IOPS"
          region  = var.region
          metrics = [
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", var.rds_instance_id],
            [".", "WriteIOPS", ".", "."]
          ]
          period = 300
          stat   = "Average"
          yAxis = {
            left = {
              label = "IOPS"
              min   = 0
            }
          }
        }
      }
    ]
  })
}