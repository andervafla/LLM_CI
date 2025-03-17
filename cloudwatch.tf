
resource "aws_cloudwatch_metric_alarm" "db_high_storage" {
  alarm_name          = "[llm]-[test]-[db]-[high]-[storage]"
  alarm_description   = "Алерт, коли в БД недостатньо вільного місця (високе використання сховища)"
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
}

resource "aws_cloudwatch_metric_alarm" "db_high_cpu" {
  alarm_name          = "[llm]-[test]-[db]-[high]-[cpu]"
  alarm_description   = "Алерт, коли CPU в БД завантажене (high CPU)"
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
}

resource "aws_cloudwatch_metric_alarm" "db_high_memory" {
  alarm_name          = "[llm]-[test]-[db]-[high]-[memory]"
  alarm_description   = "Алерт, коли використання пам'яті в БД є високим (кастомна метрика)"
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
}

resource "aws_cloudwatch_metric_alarm" "ec2_low_cpu" {
  alarm_name          = "[llm]-[test]-[ec2]-[low]-[cpu]"
  alarm_description   = "Алерт, коли завантаження CPU на EC2 є низьким"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = 20             
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    InstanceId = aws_instance.bastion.id  
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name          = "[llm]-[test]-[ec2]-[high]-[cpu]"
  alarm_description   = "Алерт, коли завантаження CPU на EC2 є високим"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80            
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_low_memory" {
  alarm_name          = "[llm]-[test]-[ec2]-[low]-[memory]"
  alarm_description   = "Алерт, коли використання пам'яті на EC2 є низьким (кастомна метрика)"
  namespace           = "LLM/Custom"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = 20            
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_high_memory" {
  alarm_name          = "[llm]-[test]-[ec2]-[high]-[memory]"
  alarm_description   = "Алерт, коли використання пам'яті на EC2 є високим (кастомна метрика)"
  namespace           = "LLM/Custom"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80             
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_low_disk_space" {
  alarm_name          = "[llm]-[test]-[ec2]-[low]-[disk-space]"
  alarm_description   = "Алерт, коли вільного дискового простору на EC2 недостатньо (низький рівень)"
  namespace           = "LLM/Custom"
  metric_name         = "DiskSpaceUtilization"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = 20             
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    InstanceId = aws_instance.bastion.id
    Filesystem = "/"             
  }
}


resource "aws_cloudwatch_metric_alarm" "ec2_high_disk_space" {
  alarm_name          = "[llm]-[test]-[ec2]-[high]-[disk-space]"
  alarm_description   = "Алерт, коли використання дискового простору на EC2 є високим (кастомна метрика)"
  namespace           = "LLM/Custom"
  metric_name         = "DiskSpaceUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80            
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    InstanceId = aws_instance.bastion.id
    Filesystem = "/"
  }
}

resource "aws_cloudwatch_metric_alarm" "elb_high_host_count" {
  alarm_name          = "[llm]-[test]-[elb]-[high]-[host-count]"
  alarm_description   = "Алерт, коли кількість здорових хостів у ELB перевищує поріг"
  namespace           = "AWS/ELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 5             
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    LoadBalancerName = aws_lb.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "elb_medium_4xx_errors" {
  alarm_name          = "[llm]-[test]-[elb]-[medium]-[4XX-errors]"
  alarm_description   = "Алерт, коли кількість 4XX помилок у ELB перевищує середній поріг"
  namespace           = "AWS/ELB"
  metric_name         = "HTTPCode_ELB_4XX"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 50             
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    LoadBalancerName = aws_lb.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "elb_medium_5xx_errors" {
  alarm_name          = "[llm]-[test]-[elb]-[medium]-[5XX-errors]"
  alarm_description   = "Алерт, коли кількість 5XX помилок у ELB перевищує середній поріг"
  namespace           = "AWS/ELB"
  metric_name         = "HTTPCode_ELB_5XX"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 10             
  period              = 300
  evaluation_periods  = 1
  dimensions = {
    LoadBalancerName = aws_lb.main.name
  }
}
