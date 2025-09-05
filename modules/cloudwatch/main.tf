############################################
# SNS Topic for CloudWatch Alarms
############################################
resource "aws_sns_topic" "alarm_topic" {
  name = "${var.project_name}-${var.environment}-alarm-topic"
}

############################################
# SNS Subscription (Email)
############################################
resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email   # email address passed as variable
}

############################################
# CloudWatch Alarm for EC2 CPU Utilization
############################################
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300               # 5 minutes
  statistic           = "Average"
  threshold           = 70                # CPU > 70%
  alarm_description   = "This alarm triggers when EC2 CPU exceeds 70% for 10 minutes."
  actions_enabled     = true

  dimensions = {
    InstanceId = var.ansible_instance_id
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
  ok_actions    = [aws_sns_topic.alarm_topic.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-cpu-alarm"
  }
}


############################################
# RDS Free Storage Alarm (<20%)
############################################
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"

  threshold           = var.rds_storage_threshold
  alarm_description   = "Triggers when RDS free storage drops below 20%."
  actions_enabled     = true

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
  ok_actions    = [aws_sns_topic.alarm_topic.arn]
}
