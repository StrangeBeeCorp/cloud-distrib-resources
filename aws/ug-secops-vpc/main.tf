###############################
### NEW SECOPS VPC CREATION ###
###############################

######################################
### GET DATA TO EXISTING RESOURCES ###
######################################

# We look for the latest Canonical Ubuntu AMI based on search filters so that we can refer to its ID later on
data "aws_ami" "secops_ubuntu_ami" {
  most_recent = true
  owners = [var.canonical_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-????????"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

# Find public DNS zone
data "aws_route53_zone" "secops-public-dns-zone" {
  name         = var.secops_r53_public_dns_zone_name
  private_zone = false
}

#####################
### VPC & NETWORK ###
#####################

# We create a brand new "secops" VPC and subnets
# We enable DNS support to manage a private DNS zone in Route53
resource "aws_vpc" "secops-vpc" {
  cidr_block            = var.secops_vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name        = var.secops_vpc_name
    Environment = var.secops_vpc_name
  }

}

# We create the private DNS zone in Route53
resource "aws_route53_zone" "secops-private-dns-zone" {
  name = var.secops_r53_private_dns_zone_name
  comment = "Private DNS zone for the secops VPC"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.secops-vpc.id
  }

  tags = {
    Environment = var.secops_vpc_name
  }

}

# We create two public subnets for our bastion host, NAT Gateway, Internet Gateway
# This will also be used for the ALB target groups
resource "aws_subnet" "secops-public-subnet-1" {
  cidr_block        = var.secops_public_subnet_1_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az1

  tags = {
    Name = var.secops_public_subnet_1_name
    Environment = var.secops_vpc_name
  }

}

resource "aws_subnet" "secops-public-subnet-2" {
  cidr_block        = var.secops_public_subnet_2_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az2

  tags = {
    Name = var.secops_public_subnet_2_name
    Environment = var.secops_vpc_name
  }

}

# We create two private subnets to host our instances
resource "aws_subnet" "secops-private-subnet-1" {
  cidr_block        = var.secops_private_subnet_1_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az1

  tags = {
    Name = var.secops_private_subnet_1_name
    Environment = var.secops_vpc_name
  }

}

resource "aws_subnet" "secops-private-subnet-2" {
  cidr_block        = var.secops_private_subnet_2_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az2

  tags = {
    Name = var.secops_private_subnet_2_name
    Environment = var.secops_vpc_name
  }

}

# We create a route table for our public subnets to be allowed to use the Internet Gateway
# and associate the route table with its subnets
resource "aws_route_table" "secops-public-route-table" {
  vpc_id = aws_vpc.secops-vpc.id

  tags = {
    Name = var.secops_public_route_table_name
    Environment = var.secops_vpc_name
  }

}

resource "aws_route_table_association" "secops-public-subnet-1-association" {
  route_table_id = aws_route_table.secops-public-route-table.id
  subnet_id      = aws_subnet.secops-public-subnet-1.id
}

resource "aws_route_table_association" "secops-public-subnet-2-association" {
  route_table_id = aws_route_table.secops-public-route-table.id
  subnet_id      = aws_subnet.secops-public-subnet-2.id
}

# We create a route table for our private subnets to be allowed to reach the public subnet 
# to use the NAT Gateway and associate the route table with both subnets
resource "aws_route_table" "secops-private-route-table" {
  vpc_id = aws_vpc.secops-vpc.id

  tags = {
    Name = var.secops_private_route_table_name
    Environment = var.secops_vpc_name
  }
}

resource "aws_route_table_association" "secops-private-subnet-1-association" {
  route_table_id = aws_route_table.secops-private-route-table.id
  subnet_id      = aws_subnet.secops-private-subnet-1.id
}

resource "aws_route_table_association" "secops-private-subnet-2-association" {
  route_table_id = aws_route_table.secops-private-route-table.id
  subnet_id      = aws_subnet.secops-private-subnet-2.id
}

# We create the Internet Gateway and add a route to it in the public route table
resource "aws_internet_gateway" "secops-vpc-igw" {
  vpc_id = aws_vpc.secops-vpc.id

  tags = {
    Name = var.secops_igw_name
    Environment = var.secops_vpc_name
  }

}

resource "aws_route" "secops-private-internet-gw-route" {
  route_table_id         = aws_route_table.secops-public-route-table.id
  gateway_id             = aws_internet_gateway.secops-vpc-igw.id
  destination_cidr_block = "0.0.0.0/0"

}

# We create a NAT Gateway within public subnet 1
resource "aws_eip" "secops-nat-gw-eip" {
  vpc      = true

  tags = {
    Name = var.secops_natgw_eip
    Environment = var.secops_vpc_name
  }

}

resource "aws_nat_gateway" "secops-nat-gw" {
  allocation_id = aws_eip.secops-nat-gw-eip.id
  subnet_id     = aws_subnet.secops-public-subnet-1.id

  tags = {
    Name = var.secops_natgw_name
    Environment = var.secops_vpc_name
  }

}

# We create a route to allow the private subnets to reach the Internet through 
# the NAT Gateway in the public subnet 
resource "aws_route" "secops-public-subnet-nat-gw-route" {
  route_table_id         = aws_route_table.secops-private-route-table.id
  nat_gateway_id         = aws_nat_gateway.secops-nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

#######################
### SECURITY GROUPS ###
#######################

# We create a security group to allow SSH access to our bastion host in the public subnet
resource "aws_security_group" "secops-public-ssh-sg" {
  name        = var.secops_public_ssh_sg_name
  description = "secops public SSH access to jumphost"
  vpc_id      = aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = var.secops_public_ssh_sg_name
    Environment = var.secops_vpc_name
  }

}

# We create the ingress rule to allow public SSH access from a whitelist in a variable
resource "aws_security_group_rule" "secops-public-ssh-sg-allow-ssh" {
  for_each        = var.secops_ssh_users_cidr
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 22
  to_port         = 22
  cidr_blocks     = [each.value]
  security_group_id = aws_security_group.secops-public-ssh-sg.id
  description     = each.key
}

# We create an egress rule to allow outgoing SSH traffic from the bastion host to TheHive and Cortex instances
resource "aws_security_group_rule" "secops-public-ssh-sg-allow-egress" {
  type            = "egress"
  protocol        = "tcp"
  from_port       = 22
  to_port         = 22
  source_security_group_id = aws_security_group.secops-ssh-sg.id
  security_group_id = aws_security_group.secops-public-ssh-sg.id
  description     = "SSH access from bastion host to private TheHive and Cortex instances"
}

# We create a security group to allow SSH access to our instances in the private subnets from the bastion host
resource "aws_security_group" "secops-ssh-sg" {
  name        = var.secops_private_ssh_sg_name
  description = "secops SSH access to EC2 Instances"
  vpc_id      = aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = var.secops_private_ssh_sg_name
    Environment = var.secops_vpc_name
  }

}

# We create the ingress rule to allow public SSH access from the bastion host
resource "aws_security_group_rule" "secops-ssh-sg-allow-ssh" {
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 22
  to_port         = 22
  source_security_group_id = aws_security_group.secops-public-ssh-sg.id
  security_group_id = aws_security_group.secops-ssh-sg.id
  description     = "SSH access to instances from bastion host"
}

# We create an egress rule to allow all outgoing traffic from our instances (customize this to your needs / context)
resource "aws_security_group_rule" "secops-ssh-sg-allow-egress" {
  type            = "egress"
  protocol        = "-1"
  from_port       = 0
  to_port         = 0
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = aws_security_group.secops-ssh-sg.id
}

###############################
### ACM Certificate for ALB ###
###############################

# We create a certificate for our ALB listener with a dimain name and additional subject alternate names (SANs)
resource "aws_acm_certificate" "secops-acm-cert" {
  domain_name       = var.secops_r53_record
  subject_alternative_names = var.secops_r53_records_san
  validation_method = "DNS"

  tags = {
    Name = var.secops_r53_record
    Environment = var.secops_vpc_name
  }

}

# We create the DNS record to validate the certificate
resource "aws_route53_record" "secops-acm-cert-r53-records" {
  for_each = {
    for dvo in aws_acm_certificate.secops-acm-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.secops-public-dns-zone.zone_id
}

# We get a validated certificate
resource "aws_acm_certificate_validation" "secops-acm-cert-validation" {
  certificate_arn         = aws_acm_certificate.secops-acm-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.secops-acm-cert-r53-records : record.fqdn]
}

############################
### ALB Client Filtering ###
############################

# We create a security group to manage end-user access to the Application Load Balancer
resource "aws_security_group" "secops-lb-access-sg" {
  name = var.secops_public_alb_access_sg_name
  description = "End-users access to Application Load Balancer"
  vpc_id                  = aws_vpc.secops-vpc.id
 
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.secops_public_alb_access_sg_name
    Environment = var.secops_vpc_name
  }

}

# We add a rule to allow ingress traffic to ALB from whitelisted end-users on port 443
# You may want to open this more broadly once your deployment is production ready
resource "aws_security_group_rule" "secops-lb-access-sg-allow-web" {
  for_each        = var.secops_users_cidr
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 443
  to_port         = 443
  cidr_blocks     = [each.value]
  security_group_id = aws_security_group.secops-lb-access-sg.id
  description     = each.key
}

# We add a rule to allow ingress traffic to ALB from whitelisted end-users on port 80
# to allow redirection to port 443.
# You may want to open this more broadly once your deployment is production ready
resource "aws_security_group_rule" "secops-lb-access-sg-allow-web-http" {
  for_each        = var.secops_users_cidr
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 80
  to_port         = 80
  cidr_blocks     = [each.value]
  security_group_id = aws_security_group.secops-lb-access-sg.id
  description     = each.key
}

#########################
### GLOBAL ALB CONFIG ###
#########################

# We create an Application Load Balancer and attach the security group
# allowing access to TheHive and Cortex instances
resource "aws_lb" "secops-alb" {
  name                    = var.secops_alb_name
  internal                = "false"
  load_balancer_type      = "application"

  security_groups         = [aws_security_group.secops-lb-access-sg.id]
  subnets                 = [aws_subnet.secops-public-subnet-1.id, aws_subnet.secops-public-subnet-2.id]

  tags = {
    Name = var.secops_alb_name
    Environment = var.secops_vpc_name
  }

}

# We create the ALB listener with no default forwarding rule (they will be created with each client environment)
# In our example, the certificate already exists with valid hostnames for prod, dev and test environments
resource "aws_lb_listener" "secops-alb-listener" {
  load_balancer_arn       = aws_lb.secops-alb.id
  port                    = "443"
  protocol                = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  certificate_arn   = aws_acm_certificate_validation.secops-acm-cert-validation.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Oops. Please check your URL again, something must be wrong..."
      status_code  = "200"
    }
  }
}

# We create a second ALB listener that simply forwards HTTP traffic to HTTPS
resource "aws_lb_listener" "secops-alb-listener-http" {
  load_balancer_arn       = aws_lb.secops-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# We create a DNS record in our public zone for end-users to connect to apps behind the ALB
resource "aws_route53_record" "secops-dns-record-alb" {
  zone_id                 = data.aws_route53_zone.secops-public-dns-zone.zone_id
  name                    = var.secops_r53_record
  type    = "A"

  alias {
    name                   = aws_lb.secops-alb.dns_name
    zone_id                = aws_lb.secops-alb.zone_id
    evaluate_target_health = true
  }
}

# We create additional DNS records for subject alternate names (SANs) to apps behind the ALB
resource "aws_route53_record" "secops-dns-record-alb-san" {
  for_each        = toset(var.secops_r53_records_san)
  allow_overwrite = true
  name            = each.key
  type            = "A"
  zone_id         = data.aws_route53_zone.secops-public-dns-zone.zone_id

  alias {
    name                   = aws_lb.secops-alb.dns_name
    zone_id                = aws_lb.secops-alb.zone_id
    evaluate_target_health = true
  }
}

########################
### SHARED INSTANCES ###
########################

# We create a keypair to connect to our bastion host instance
resource "aws_key_pair" "secops_bastion_key_pair" {
  key_name   = var.secops_key_pair_name
  public_key = var.secops_key_pair_public_key

  tags = {
    Environment = var.secops_vpc_name
  }

}

# We create the bastion host instance based on the various variables we have already set
resource "aws_instance" "bastion-host-secops" {
  ami           = data.aws_ami.secops_ubuntu_ami.id
  instance_type = var.secops_bastion_ec2_instance_type
  subnet_id = aws_subnet.secops-public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.secops-public-ssh-sg.id]
  key_name = aws_key_pair.secops_bastion_key_pair.key_name
  user_data = templatefile("files/bastion-cloud-config-new.tpl", {
    hostname = var.secops_bastion_ec2_instance_name
  })

  root_block_device {
    tags = {
      Name = var.secops_bastion_ec2_instance_os_name
      SourceInstance = var.secops_bastion_ec2_instance_name
      Environment = var.secops_vpc_name
    }  
  } 

  tags = {
    Name = var.secops_bastion_ec2_instance_name
    Environment = var.secops_vpc_name
  }
}

# We allocate a public IP to the bastion host instance
resource "aws_eip" "bastion-host-secops-eip" {
  instance = aws_instance.bastion-host-secops.id
  vpc      = true

  tags = {
    Name = var.secops_bastion_eip
    Environment = var.secops_vpc_name
  }
}

