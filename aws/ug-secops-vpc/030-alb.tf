# We create an Application Load Balancer and attach the security group
# allowing access to TheHive and Cortex instances
resource "aws_lb" "secops-alb" {
  name                    = "secops-alb"
  internal                = "false"
  load_balancer_type      = "application"

  security_groups         = [aws_security_group.secops-lb-access-sg.id]
  subnets                 = [aws_subnet.secops-public-subnet-1.id, aws_subnet.secops-public-subnet-2.id]

  tags = {
    Name = "secops-alb"
  }
}

# We create the ALB listener with a default rule to forward traffic to TheHive
# In our example, the certificate already exists with valid hostnames for both TheHive and Cortex
resource "aws_lb_listener" "secops-alb-listener" {
  load_balancer_arn       = aws_lb.secops-alb.id
  port                    = "443"
  protocol                = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.secops_alb_certificate

  default_action {
    target_group_arn      = aws_lb_target_group.secops-alb-thehive-tg.id
    type                  = "forward"
  }
}

# We create an additional forward rule for Cortex forwarding (hostname = cortex.domain.name)
resource "aws_lb_listener_rule" "secops-alb-listener-rule-cortex" {
  listener_arn = aws_lb_listener.secops-alb-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.secops-alb-cortex-tg.id
  }

  condition {
    host_header {
      values = ["cortex.*"]
    }
  }
}

# We create a first target group for TheHive
resource "aws_lb_target_group" "secops-alb-thehive-tg" {
  name                    = "secops-alb-thehive-tg"
  vpc_id                  = aws_vpc.secops-vpc.id

  port                    = "9000"
  protocol                = "HTTP"

  health_check {
      protocol = "HTTP"
      port     = "9000"
      path     = "/index.html"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "secops-alb-thehive-tg"
  }
}

# We create a second target group for Cortex
resource "aws_lb_target_group" "secops-alb-cortex-tg" {
  name                    = "secops-alb-cortex-tg"
  vpc_id                  = aws_vpc.secops-vpc.id

  port                    = "9001"
  protocol                = "HTTP"

  health_check {
      protocol = "HTTP"
      port     = "9001"
      path     = "/index.html"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "secops-alb-cortex-tg"
  }
}

# We create a DNS record in our public zone for end-users to connect to TheHive on the ALB
resource "aws_route53_record" "secops-dns-record-alb-thehive" {
  zone_id                 = var.secops_r53_public_dns_zone_id
  name                    = var.secops_r53_thehive_record
  type    = "A"

  alias {
    name                   = aws_lb.secops-alb.dns_name
    zone_id                = aws_lb.secops-alb.zone_id
    evaluate_target_health = true
  }
}

# We create a DNS record in our public zone for end-users to connect to Cortex on the ALB
resource "aws_route53_record" "secops-dns-record-alb-cortex" {
  zone_id                 = var.secops_r53_public_dns_zone_id
  name                    = var.secops_r53_cortex_record
  type    = "A"

  alias {
    name                   = aws_lb.secops-alb.dns_name
    zone_id                = aws_lb.secops-alb.zone_id
    evaluate_target_health = true
  }
}