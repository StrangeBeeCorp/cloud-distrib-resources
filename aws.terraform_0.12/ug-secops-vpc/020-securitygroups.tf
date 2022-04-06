# We create a security group to allow SSH access to our bastion host in the public subnet
resource "aws_security_group" "secops-public-ssh-sg" {
  name        = "secops-public-ssh-sg"
  description = "secops public SSH access to jumphost"
  vpc_id      = aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "secops-public-ssh-sg"
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

# Alternate egress rule to allow all outgoing traffic from the bastion host (customize this to your needs / context)
# resource "aws_security_group_rule" "secops-public-ssh-sg-allow-egress" {
#   type            = "egress"
#   protocol        = "-1"
#   from_port       = 0
#   to_port         = 0
#   cidr_blocks     = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.secops-public-ssh-sg.id
# }

# We create a security group to allow SSH access to our instances in the private subnets from the bastion host
resource "aws_security_group" "secops-ssh-sg" {
  name        = "secops-ssh-sg"
  description = "secops SSH access to EC2 Instances"
  vpc_id      = aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "secops-ssh-sg"
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

# We create a security group to allow application access to TheHive instance (http port 9000)
# This is not for end-users, it's to allow public-facing systems such as a load balancer or
# a reverse proxy to reach TheHive
resource "aws_security_group" "secops-thehive-sg" {
  name        = "secops-thehive-sg"
  description = "Application access to TheHive instance"
  vpc_id      = aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "secops-thehive-sg"
  }
}

# We create a security group to allow application access to Cortex instance (http port 9001)
# This is not for end-users, it's to allow public-facing systems such as a load balancer or
# a reverse proxy and TheHive instance to reach Cortex
resource "aws_security_group" "secops-cortex-sg" {
  name        = "secops-cortex-sg"
  description = "Application access to Cortex instance"
  vpc_id      = aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "secops-cortex-sg"
  }
}

# We add a rule to allow ingress traffic from TheHive to Cortex instance on port 9001
resource "aws_security_group_rule" "secops-cortex-sg-allow-thehive" {
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 9001
  to_port         = 9001
  source_security_group_id = aws_security_group.secops-thehive-sg.id
  security_group_id = aws_security_group.secops-cortex-sg.id
  description     = "Access to Cortex from TheHive on port 9001"
}

# We create a security group to manage end-user access to the Application Load Balancer
resource "aws_security_group" "secops-lb-access-sg" {
  name = "secops-lb-access-sg"
  description = "End-users access to Application Load Balancer"
  vpc_id                  = aws_vpc.secops-vpc.id
 
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "secops-lb-access-sg"
  }
}

# We add a rule to allow egress traffic from the ALB 
# to be forwarded to TheHive instance security group on port 9000
resource "aws_security_group_rule" "secops-lb-access-sg-allow-egress-thehive" {
  type            = "egress"
  protocol        = "tcp"
  from_port       = 9000
  to_port         = 9000
  source_security_group_id = aws_security_group.secops-thehive-sg.id
  security_group_id = aws_security_group.secops-lb-access-sg.id
  description     = "Access from ALB to backend TheHive instances in the target group on port 9000"
}

# We add a rule to allow egress traffic from the ALB 
# to be forwarded to Cortex instance security group on port 9001
resource "aws_security_group_rule" "secops-lb-access-sg-allow-egress-cortex" {
  type            = "egress"
  protocol        = "tcp"
  from_port       = 9001
  to_port         = 9001
  source_security_group_id = aws_security_group.secops-cortex-sg.id
  security_group_id = aws_security_group.secops-lb-access-sg.id
  description     = "Access from ALB to backend Cortex instances in the target group on port 9001"
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

# We add a rule to allow ingress traffic from ALB to TheHive instances on port 9000
resource "aws_security_group_rule" "secops-thehive-sg-allow-alb" {
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 9000
  to_port         = 9000
  source_security_group_id = aws_security_group.secops-lb-access-sg.id
  security_group_id = aws_security_group.secops-thehive-sg.id
  description     = "Access from ALB on port 9000"
}

# We add a rule to allow ingress traffic from ALB to Cortex instances on port 9001
resource "aws_security_group_rule" "secops-cortex-sg-allow-alb" {
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 9001
  to_port         = 9001
  source_security_group_id = aws_security_group.secops-lb-access-sg.id
  security_group_id = aws_security_group.secops-cortex-sg.id
  description     = "Access from ALB on port 9001"
}