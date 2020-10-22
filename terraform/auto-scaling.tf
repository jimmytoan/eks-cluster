#
# Auto scaling policy based on CPU ultilization
#

resource "aws_autoscaling_policy" "auto-scaling-cpu-utilization" {
  name                      = "auto-scaling-cpu-utilization"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.eks.name
  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "70"
  }
}