output "ecs_health_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ecs_health_alarm.alarm_name
}

output "ecs_running_tasks_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ecs_running_tasks_alarm.alarm_name
}

output "failover_composite_alarm_name" {
  value = aws_cloudwatch_composite_alarm.failover_trigger_alarm.alarm_name
}
