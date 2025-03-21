resource "aws_sns_topic" "alerts_topic" {
  name = "alerts-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts_topic.arn
  protocol  = "email"
  endpoint  = "andervafla@gmail.com" 
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_host_count" {
  alarm_name          = "[llm]-[test]-[alb]-[high]-[unhealthy-host-count]"
  alarm_description   = "unhealthy-host-count"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.tg.arn_suffix
  }
  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}


resource "aws_cloudwatch_metric_alarm" "alb_4xx_errors" {
  alarm_name          = "[llm]-[test]-[alb]-[medium]-[4XX-errors]"
  alarm_description   = "4xx errors"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_4XX_Count"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 50
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "[llm]-[test]-[alb]-[medium]-[5XX-errors]"
  alarm_description   = "5xx errors"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 10
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "db_high_storage" {
  alarm_name          = "[llm]-[test]-[db]-[high]-[storage]"
  alarm_description   = "db high storage"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = 1000000000
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds_instance.id
  }
  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "db_high_cpu" {
  alarm_name          = "[llm]-[test]-[db]-[high]-[cpu]"
  alarm_description   = "db high CPU"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds_instance.id
  }
  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "db_high_memory" {
  alarm_name          = "[llm]-[test]-[db]-[high]-[memory]"
  alarm_description   = "db high memory"
  namespace           = "LLM/Custom"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds_instance.id
  }
  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}
