# create launch template for asg 
resource "aws_launch_template" "apci_lt" {
  name = "apci_lt"
  image_id = var.image_id
  key_name = var.key_name
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups = var.frontend_subnet_ids
  }


    tags = merge(var.tags,
    {
    Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-APCI_lt"
    }
    )

}


#create autoscaling group

resource "aws_autoscaling_group" "apci_asg" {
  name = "apci-asg"
  desired_capacity = 3
  max_size = 4
  min_size = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  vpc_zone_identifier = var.frontend_subnet_ids[*]
  target_group_arns = [var.target_group_arn]


  launch_template {
    id = aws_launch_template.apci_lt.id
    version = "$Latest"
  }

 tags = merge(var.tags,
    {
    Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-asg"
    }
    )

}

resource "aws_autoscaling_policy" "cpu_utilization" {
  name = "auto_target_tracking"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.apci_asg.name
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
    disable_scale_in = false
  }


}