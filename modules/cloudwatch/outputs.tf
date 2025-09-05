output "sns_topic_arn" {
  value = aws_sns_topic.alarm_topic.arn
}

output "cloudwatch_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu_high.alarm_name
}
