
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
    alarm_name          = "HighCPUUtilization"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "80"

    dimensions = {
        InstanceId = module.ec2_instance.instance_id
    }

}