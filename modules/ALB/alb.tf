
#create a target group for the application load balancer
resource "aws_alb_target_group" "apci_tg" {
  name = "apci_tg"
  vpc_id = var.vpc_id
  target_type = "instance"
  protocol = "HTTP"
  port = 80

    tags = {
      Name = apci_tg
    }
}


##################################################################################################################################
#create ALB to distribute traffic to autoscaling group

resource "aws_lb" "apci_alb" {
  name = "apci_alb"
  load_balancer_type = "application"
  internal = false
  subnets = var.frontend_subnet_ids[*]
  security_groups = [var.apci_ALB_sg]


   tags = merge(var.tags,
        {
            Name = "${var.tags.project}-${var.tags.application}-${var.tags.environment}-${var.tags.owner}-apci_alb" 
        }
    )
}

# create alb listerners for HTTP and HTTPS with redirect default action

resource "aws_alb_listener" "HTTP" {
  load_balancer_arn = aws_lb.apci_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.apci_alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.ssl_certificate.arn

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.apci_tg.arn
  }
}



  data "aws_acm_certificate" "ssl_certificate" {
    domain = var.domain
    most_recent = true
    status ="ISSUED"

  }