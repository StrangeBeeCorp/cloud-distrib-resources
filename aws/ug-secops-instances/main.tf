#####################################################
### MANAGING A SECOPS ENV WITH THEHIVE & CORTEX   ###
#####################################################

######################################
### GET DATA TO EXISTING RESOURCES ###
######################################

# Destination VPC
data "aws_vpc" "secops-vpc" {
  filter {
    name   = "tag:Name"
    values = [var.secops_vpc_name]
  }
}

# Load Balancer resources
data "aws_security_group" "secops-lb-access-sg" {
  filter {
    name   = "tag:Name"
    values = [var.secops_public_alb_access_sg_name]
  }
}

data "aws_lb" "secops-alb" {
  name = var.secops_alb_name
}

data "aws_lb_listener" "secops-alb-listener" {
  load_balancer_arn = data.aws_lb.secops-alb.arn
  port              = 443
}

# SSH security group
data "aws_security_group" "secops-sg-ssh" {
  filter {
    name   = "tag:Name"
    values = [var.secops_ssh-sg_name]
  }
}

# Destination subnet
data "aws_subnet" "secops-private-subnet-1" {
  filter {
    name   = "tag:Name"
    values = [var.secops_private-subnet-1_name]
  }
}

# TheHive AMI
data "aws_ami" "secops_thehive_ami" {
  most_recent = true
  owners = [var.strangebee_account_number]

  filter {
    name   = "name"
    values = [var.secops_thehive-ami-name]
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

# Cortex AMI
data "aws_ami" "secops_cortex_ami" {
  most_recent = true
  owners = [var.strangebee_account_number]

  filter {
    name   = "name"
    values = [var.secops_cortex-ami-name]
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

# Private DNS zone
data "aws_route53_zone" "secops-vpc-dns-zone" {
  name         = var.secops_vpc-dns-zone-name
  private_zone = true
}

# We find the TheHive data volume we will be using as source for the new instance
data "aws_ebs_volume" "secops-thehive-data-volume" {
  count       = var.secops_thehive_init ? 0 : 1
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "tag:SourceInstance"
    values = ["${var.secops_vpc_name}-${var.secops_thehive_dns-record}"]
  }

  filter {
    name   = "tag:SourceInstanceVolume"
    values = ["/dev/sdh"]
  }
}

# We find the TheHive attachments volume we will be using as source for the new instance
data "aws_ebs_volume" "secops-thehive-attachments-volume" {
  count       = var.secops_thehive_init ? 0 : 1
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "tag:SourceInstance"
    values = ["${var.secops_vpc_name}-${var.secops_thehive_dns-record}"]
  }

  filter {
    name   = "tag:SourceInstanceVolume"
    values = ["/dev/sdi"]
  }
}

# We find the TheHive index volume we will be using as source for the new instance
data "aws_ebs_volume" "secops-thehive-index-volume" {
  count       = var.secops_thehive_init ? 0 : 1
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "tag:SourceInstance"
    values = ["${var.secops_vpc_name}-${var.secops_thehive_dns-record}"]
  }

  filter {
    name   = "tag:SourceInstanceVolume"
    values = ["/dev/sdj"]
  }
}

# We create a snapshot of the TheHive data volume to base our new data volume upon
# This way we never touch the original / previous EBS data volume
resource "aws_ebs_snapshot" "secops-thehive-data-snapshot" {
  count       = var.secops_thehive_init ? 0 : 1
  volume_id = data.aws_ebs_volume.secops-thehive-data-volume[count.index].id

  tags = {
    Name = "${var.secops_thehive_instance_name}-data-snapshot"
  }
}

# We create a snapshot of the TheHive attachments volume to base our new attachments volume upon
# This way we never touch the original / previous EBS attachments volume
resource "aws_ebs_snapshot" "secops-thehive-attachments-snapshot" {
  count       = var.secops_thehive_init ? 0 : 1
  volume_id = data.aws_ebs_volume.secops-thehive-attachments-volume[count.index].id

  tags = {
    Name = "${var.secops_thehive_instance_name}-attachments-snapshot"
  }
}

# We create a snapshot of the TheHive index volume to base our new index volume upon
# This way we never touch the original / previous EBS index volume
resource "aws_ebs_snapshot" "secops-thehive-index-snapshot" {
  count       = var.secops_thehive_init ? 0 : 1
  volume_id = data.aws_ebs_volume.secops-thehive-index-volume[count.index].id

  tags = {
    Name = "${var.secops_thehive_instance_name}-index-snapshot"
  }
}

# We find the Cortex data volume we will be using as source for the new instance
data "aws_ebs_volume" "secops-cortex-data-volume" {
  count       = var.secops_cortex_init ? 0 : 1
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "tag:SourceInstance"
    values = ["${var.secops_vpc_name}-${var.secops_cortex_dns-record}"]
  }

  filter {
    name   = "tag:SourceInstanceVolume"
    values = ["/dev/sdh"]
  }
}

# We find the Cortex Docker volume we will be using as source for the new instance
data "aws_ebs_volume" "secops-cortex-docker-volume" {
  count       = var.secops_cortex_init ? 0 : 1
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "tag:SourceInstance"
    values = ["${var.secops_vpc_name}-${var.secops_cortex_dns-record}"]
  }

  filter {
    name   = "tag:SourceInstanceVolume"
    values = ["/dev/sdi"]
  }
}

# We create a snapshot of the Cortex data volume to base our new data volume upon
# This way we never touch the original / previous EBS data volume
resource "aws_ebs_snapshot" "secops-cortex-data-snapshot" {
  count       = var.secops_cortex_init ? 0 : 1
  volume_id = data.aws_ebs_volume.secops-cortex-data-volume[count.index].id

  tags = {
    Name = "${var.secops_cortex_instance_name}-data-snapshot"
  }
}

# We create a snapshot of the Cortex Docker volume to base our new attachments volume upon
# This way we never touch the original / previous EBS attachments volume
resource "aws_ebs_snapshot" "secops-cortex-docker-snapshot" {
  count       = var.secops_cortex_init ? 0 : 1
  volume_id = data.aws_ebs_volume.secops-cortex-docker-volume[count.index].id

  tags = {
    Name = "${var.secops_cortex_instance_name}-docker-snapshot"
  }
}

###############################
### CREATE CLIENT RESOURCES ###
###############################

#######################
### SECURITY GROUPS ###
#######################


# We create a security group to allow application access to TheHive instance (http port 9000)
# This is not for end-users, it's to allow public-facing systems such as a load balancer or
# a reverse proxy to reach TheHive
resource "aws_security_group" "secops-thehive-sg" {
  name        = var.secops_thehive_sg_name
  description = "Application access to TheHive instance"
  vpc_id      = data.aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = var.secops_thehive_sg_name
    Environment = var.secops_vpc_name
  }
}

# We create a security group to allow application access to Cortex instance (http port 9001)
# This is not for end-users, it's to allow public-facing systems such as a load balancer or
# a reverse proxy and TheHive instance to reach Cortex
resource "aws_security_group" "secops-cortex-sg" {
  name        = var.secops_cortex_sg_name
  description = "Application access to Cortex instance"
  vpc_id      = data.aws_vpc.secops-vpc.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = var.secops_cortex_sg_name
    Environment = var.secops_vpc_name
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

# We add a rule to allow egress traffic from the ALB 
# to be forwarded to TheHive instance security group on port 9000
resource "aws_security_group_rule" "secops-lb-access-sg-allow-egress-thehive" {
  type            = "egress"
  protocol        = "tcp"
  from_port       = 9000
  to_port         = 9000
  source_security_group_id = aws_security_group.secops-thehive-sg.id
  security_group_id = data.aws_security_group.secops-lb-access-sg.id
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
  security_group_id = data.aws_security_group.secops-lb-access-sg.id
  description     = "Access from ALB to backend Cortex instances in the target group on port 9001"
}

# We add a rule to allow ingress traffic from ALB to TheHive instances on port 9000
resource "aws_security_group_rule" "secops-thehive-sg-allow-alb" {
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 9000
  to_port         = 9000
  source_security_group_id = data.aws_security_group.secops-lb-access-sg.id
  security_group_id = aws_security_group.secops-thehive-sg.id
  description     = "Access from ALB on port 9000"
}

# We add a rule to allow ingress traffic from ALB to Cortex instances on port 9001
resource "aws_security_group_rule" "secops-cortex-sg-allow-alb" {
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 9001
  to_port         = 9001
  source_security_group_id = data.aws_security_group.secops-lb-access-sg.id
  security_group_id = aws_security_group.secops-cortex-sg.id
  description     = "Access from ALB on port 9001"
}

################################
### ALB CLIENT CONFIGURATION ###
################################

# We create an additional forward rule for TheHive forwarding (hostname = thehive.domain.name)
resource "aws_lb_listener_rule" "secops-alb-listener-rule-thehive" {
  listener_arn = data.aws_lb_listener.secops-alb-listener.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.secops-alb-thehive-tg.id
  }

  condition {
    host_header {
      values = ["thehive.*"]
    }
  }
}

# We create an additional forward rule for Cortex forwarding (hostname = cortex.domain.name)
resource "aws_lb_listener_rule" "secops-alb-listener-rule-cortex" {
  listener_arn = data.aws_lb_listener.secops-alb-listener.arn
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
  name                    = var.secops_thehive_tg_name
  vpc_id                  = data.aws_vpc.secops-vpc.id

  port                    = "9000"
  protocol                = "HTTP"

  health_check {
      protocol = "HTTP"
      port     = "9000"
      path     = "/index.html"
      healthy_threshold = "2"
      unhealthy_threshold = "10"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.secops_thehive_tg_name
    Environment = var.secops_vpc_name
  }
}

# We create a second target group for Cortex
resource "aws_lb_target_group" "secops-alb-cortex-tg" {
  name                    = var.secops_cortex_tg_name
  vpc_id                  = data.aws_vpc.secops-vpc.id

  port                    = "9001"
  protocol                = "HTTP"

  health_check {
      protocol = "HTTP"
      port     = "9001"
      path     = "/index.html"
      healthy_threshold = "2"
      unhealthy_threshold = "10"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.secops_cortex_tg_name
    Environment = var.secops_vpc_name
  }
}

###############################
### MANAGE THEHIVE INSTANCE ###
###############################

# We create the keypair to connect to the client instances
resource "aws_key_pair" "secops-client-keypair" {
  key_name   = var.secops_key_pair_name
  public_key = var.secops_key_pair_public_key

  tags = {
    Environment = var.secops_vpc_name
  }

}

### INIT PHASE
# Launch TheHive instance
resource "aws_instance" "secops-instance-thehive" {
  count         = var.secops_thehive_init ? 1 : 0
  ami           = data.aws_ami.secops_thehive_ami.id
  instance_type = var.secops_instance-type_thehive
  subnet_id = data.aws_subnet.secops-private-subnet-1.id
  vpc_security_group_ids = [data.aws_security_group.secops-sg-ssh.id,aws_security_group.secops-thehive-sg.id]
  key_name = var.secops_key_pair_name
  user_data = templatefile("files/th-cloud-config-new.tpl", {
    hostname = var.secops_thehive_instance_name,
  })
  root_block_device {
    volume_size = var.secops_thehive_instance_os_volume_size
    tags = {
      Name = "${var.secops_thehive_instance_name}-system"
      SourceInstance = var.secops_thehive_instance_name
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdh"
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_data_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-data"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdh"
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdi"
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_attachments_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-attachments"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdi"
      Environment = var.secops_vpc_name
    }  
  }
  ebs_block_device {
    device_name = "/dev/sdj"
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_index_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-index"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdj"
      Environment = var.secops_vpc_name
    }  
  }  

  tags = {
    Name = var.secops_thehive_instance_name
    Environment = var.secops_vpc_name
  }
}

# Attach instance to LB Target Group
resource "aws_lb_target_group_attachment" "secops-tg-attachment-thehive" {
  count         = var.secops_thehive_init ? 1 : 0
  target_group_arn = aws_lb_target_group.secops-alb-thehive-tg.arn
  target_id        = aws_instance.secops-instance-thehive[count.index].id
  port             = 9000
}

# Create DNS record for TheHive private IP
resource "aws_route53_record" "secops-private_ip-thehive" {
  zone_id = data.aws_route53_zone.secops-vpc-dns-zone.zone_id
  count         = var.secops_thehive_init ? 1 : 0
  name    = "${var.secops_thehive_dns-record}.${data.aws_route53_zone.secops-vpc-dns-zone.name}"
  type    = "A"
  ttl     = "300"
  allow_overwrite = true
  records = [aws_instance.secops-instance-thehive[count.index].private_ip]
}

### RESTORE PHASE
# Launch TheHive instance
resource "aws_instance" "secops-instance-thehive-restore" {
  count         = var.secops_thehive_init ? 0 : 1
  ami           = data.aws_ami.secops_thehive_ami.id
  instance_type = var.secops_instance-type_thehive
  subnet_id = data.aws_subnet.secops-private-subnet-1.id
  vpc_security_group_ids = [data.aws_security_group.secops-sg-ssh.id,aws_security_group.secops-thehive-sg.id]
  key_name = var.secops_key_pair_name
  user_data = templatefile("files/th-cloud-config-restore.tpl", {
    hostname = var.secops_thehive_instance_name,
  })
  root_block_device {
    volume_size = var.secops_thehive_instance_os_volume_size
    tags = {
      Name = "${var.secops_thehive_instance_name}-system"
      SourceInstance = var.secops_thehive_instance_name
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdh"
    snapshot_id = aws_ebs_snapshot.secops-thehive-data-snapshot[count.index].id
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_data_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-data"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdh"
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdi"
    snapshot_id = aws_ebs_snapshot.secops-thehive-attachments-snapshot[count.index].id
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_attachments_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-attachments"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdi"
      Environment = var.secops_vpc_name
    }  
  }
  ebs_block_device {
    device_name = "/dev/sdj"
    snapshot_id = aws_ebs_snapshot.secops-thehive-index-snapshot[count.index].id
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_index_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-index"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdj"
      Environment = var.secops_vpc_name
    }  
  }  

  tags = {
    Name = var.secops_thehive_instance_name
    Environment = var.secops_vpc_name
  }
}

# Attach instance to LB Target Group
resource "aws_lb_target_group_attachment" "secops-tg-attachment-thehive-restore" {
  count         = var.secops_thehive_init ? 0 : 1
  target_group_arn = aws_lb_target_group.secops-alb-thehive-tg.arn
  target_id        = aws_instance.secops-instance-thehive-restore[count.index].id
  port             = 9000
}

# Create DNS record for TheHive private IP
resource "aws_route53_record" "secops-private_ip-thehive-restore" {
  count         = var.secops_thehive_init ? 0 : 1
  zone_id = data.aws_route53_zone.secops-vpc-dns-zone.zone_id
  name    = "${var.secops_thehive_dns-record}.${data.aws_route53_zone.secops-vpc-dns-zone.name}"
  type    = "A"
  ttl     = "300"
  allow_overwrite = true
  records = [aws_instance.secops-instance-thehive-restore[count.index].private_ip]
}

###############################
### MANAGE CORTEX INSTANCE ###
###############################

### INIT PHASE
# Launch instance
resource "aws_instance" "secops-instance-cortex" {
  count         = var.secops_cortex_init ? 1 : 0
  ami           = data.aws_ami.secops_cortex_ami.id
  instance_type = var.secops_instance-type_cortex
  subnet_id = data.aws_subnet.secops-private-subnet-1.id
  vpc_security_group_ids = [data.aws_security_group.secops-sg-ssh.id,aws_security_group.secops-cortex-sg.id]
  key_name = var.secops_key_pair_name
  user_data = templatefile("files/cortex-cloud-config-new.tpl", {
    hostname = var.secops_cortex_instance_name,
  })
  root_block_device {
    volume_size = var.secops_cortex_instance_os_volume_size
    tags = {
      Name = "${var.secops_cortex_instance_name}-system"
      SourceInstance = var.secops_cortex_instance_name
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdh"
    volume_type = "gp2"
    volume_size = var.secops_cortex_instance_data_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_cortex_instance_name}-data"
      SourceInstance = var.secops_cortex_instance_name
      SourceInstanceVolume = "/dev/sdh"
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdi"
    volume_type = "gp2"
    volume_size = var.secops_cortex_instance_docker_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_cortex_instance_name}-docker"
      SourceInstance = var.secops_cortex_instance_name
      SourceInstanceVolume = "/dev/sdi"
      Environment = var.secops_vpc_name
    }  
  } 

  tags = {
    Name = var.secops_cortex_instance_name
    Environment = var.secops_vpc_name
  }
}

resource "aws_lb_target_group_attachment" "secops-tg-attachment-cortex" {
  count         = var.secops_cortex_init ? 1 : 0
  target_group_arn = aws_lb_target_group.secops-alb-cortex-tg.arn
  target_id        = aws_instance.secops-instance-cortex[count.index].id
  port             = 9001
}

# Create DNS record for Cortex private IP
resource "aws_route53_record" "secops-private_ip-cortex" {
  count         = var.secops_cortex_init ? 1 : 0
  zone_id = data.aws_route53_zone.secops-vpc-dns-zone.zone_id
  name    = "${var.secops_cortex_dns-record}.${data.aws_route53_zone.secops-vpc-dns-zone.name}"
  type    = "A"
  ttl     = "300"
  allow_overwrite = true
  records = [aws_instance.secops-instance-cortex[count.index].private_ip]
}

### RESTORE PHASE
# Launch instance
resource "aws_instance" "secops-instance-cortex-restore" {
  count         = var.secops_cortex_init ? 0 : 1
  ami           = data.aws_ami.secops_cortex_ami.id
  instance_type = var.secops_instance-type_cortex
  subnet_id = data.aws_subnet.secops-private-subnet-1.id
  vpc_security_group_ids = [data.aws_security_group.secops-sg-ssh.id,aws_security_group.secops-cortex-sg.id]
  key_name = var.secops_key_pair_name
  user_data = templatefile("files/cortex-cloud-config-restore.tpl", {
    hostname = var.secops_cortex_instance_name,
  })
  root_block_device {
    volume_size = var.secops_cortex_instance_os_volume_size
    tags = {
      Name = "${var.secops_cortex_instance_name}-system"
      SourceInstance = var.secops_cortex_instance_name
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdh"
    snapshot_id = aws_ebs_snapshot.secops-cortex-data-snapshot[count.index].id
    volume_type = "gp2"
    volume_size = var.secops_cortex_instance_data_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_cortex_instance_name}-data"
      SourceInstance = var.secops_cortex_instance_name
      SourceInstanceVolume = "/dev/sdh"
      Environment = var.secops_vpc_name
    }  
  } 
  ebs_block_device {
    device_name = "/dev/sdi"
    snapshot_id = aws_ebs_snapshot.secops-cortex-docker-snapshot[count.index].id
    volume_type = "gp2"
    volume_size = var.secops_cortex_instance_docker_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_cortex_instance_name}-docker"
      SourceInstance = var.secops_cortex_instance_name
      SourceInstanceVolume = "/dev/sdi"
      Environment = var.secops_vpc_name
    }  
  } 

  tags = {
    Name = var.secops_cortex_instance_name
    Environment = var.secops_vpc_name
  }
}

resource "aws_lb_target_group_attachment" "secops-tg-attachment-cortex-restore" {
  count         = var.secops_cortex_init ? 0 : 1
  target_group_arn = aws_lb_target_group.secops-alb-cortex-tg.arn
  target_id        = aws_instance.secops-instance-cortex-restore[count.index].id
  port             = 9001
}

# Create DNS record for Cortex private IP
resource "aws_route53_record" "secops-private_ip-cortex-restore" {
  count         = var.secops_cortex_init ? 0 : 1
  zone_id = data.aws_route53_zone.secops-vpc-dns-zone.zone_id
  name    = "${var.secops_cortex_dns-record}.${data.aws_route53_zone.secops-vpc-dns-zone.name}"
  type    = "A"
  ttl     = "300"
  allow_overwrite = true
  records = [aws_instance.secops-instance-cortex-restore[count.index].private_ip]
}
