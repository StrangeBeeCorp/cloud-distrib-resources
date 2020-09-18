# We find the Cortex data and Docker volumes we will be restoring
data "aws_ebs_volume" "secops-cortex-data-volume" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "volume-id"
    values = ["${var.secops-cortex-data-volume_id}"]
  }
}

data "aws_ebs_volume" "secops-cortex-docker-volume" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "volume-id"
    values = ["${var.secops-cortex-docker-volume_id}"]
  }
}

# We create snapshots of the Cortex data and Docker volumes to base our new volumes upon
# This way we never touch the original / previous EBS volumes
resource "aws_ebs_snapshot" "secops-cortex-data-snapshot" {
  volume_id = data.aws_ebs_volume.secops-cortex-data-volume.id

  tags = {
    Name = "cortex-data-snapshot"
  }
}

resource "aws_ebs_snapshot" "secops-cortex-docker-snapshot" {
  volume_id = data.aws_ebs_volume.secops-cortex-docker-volume.id

  tags = {
    Name = "cortex-docker-snapshot"
  }
}

# We create a keypair to connect to our Cortex instance
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.secops_key_pair_name
  public_key = var.secops_key_pair_public_key
}

# We create the Cortex instance based on the various variables we have already set
# The cloud-config user data file allows to partition and format the ElasticSearch and Docker EBS volumes
# and to launch the Cortex initialization script
resource "aws_instance" "cortex-secops" {
  ami           = data.aws_ami.secops_cortex_ami.id
  instance_type = var.secops_ec2_instance_type
  subnet_id = data.aws_subnet.secops-private-subnet-1.id
  vpc_security_group_ids = [data.aws_security_group.secops-sg-ssh.id,data.aws_security_group.secops-sg-cortex.id]
  key_name = aws_key_pair.ec2_key_pair.key_name
  user_data = file("files/cortex-cloud-config-restore.yaml")
  ebs_block_device {
    device_name = "/dev/sdh"
    snapshot_id = aws_ebs_snapshot.secops-cortex-data-snapshot.id
    volume_type = "gp2"
    delete_on_termination = false
  } 
  ebs_block_device {
    device_name = "/dev/sdi"
    snapshot_id = aws_ebs_snapshot.secops-cortex-docker-snapshot.id
    volume_type = "gp2"
    delete_on_termination = false
  }  
  tags = {
    Name = "cortex-secops"
  }
}

# We create a DNS record for the Cortex private IP so that we can easily connect to it through our bastion host
# and so that TheHive can easily find it within our VPC
resource "aws_route53_record" "cortex" {
  zone_id = data.aws_route53_zone.secops-vpc-dns-zone.zone_id
  name    = "cortex.${data.aws_route53_zone.secops-vpc-dns-zone.name}"
  type    = "A"
  ttl     = "300"
  allow_overwrite = true
  records = [aws_instance.cortex-secops.private_ip]
}

# We add the newly created instance to the ALB Cortex target group
resource "aws_lb_target_group_attachment" "cortex-secops-alb-tg-attachment" {
  target_group_arn = data.aws_lb_target_group.secops-alb-tg-cortex.arn
  target_id        = aws_instance.cortex-secops.id
  port             = 9001
}