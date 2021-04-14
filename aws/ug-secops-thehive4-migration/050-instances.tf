# We find the TheHive data volume we will be restoring
data "aws_ebs_volume" "secops-thehive-data-volume" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "volume-id"
    values = ["${var.secops-thehive-data-volume_id}"]
  }
}

# We find the TheHive attachments volume we will be restoring
data "aws_ebs_volume" "secops-thehive-attachments-volume" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "volume-id"
    values = ["${var.secops-thehive-attachments-volume_id}"]
  }
}

# We find the TheHive index volume we will be restoring
data "aws_ebs_volume" "secops-thehive-index-volume" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "volume-id"
    values = ["${var.secops-thehive-index-volume_id}"]
  }
}

# We create a snapshot of the TheHive data volume to base our new data volume upon
# This way we never touch the original / previous EBS data volume
resource "aws_ebs_snapshot" "secops-thehive-data-snapshot" {
  volume_id = data.aws_ebs_volume.secops-thehive-data-volume.id

  tags = {
    Name = "thehive-data-snapshot"
  }
}

# We create a snapshot of the TheHive attachments volume to base our new attachments volume upon
# This way we never touch the original / previous EBS attachments volume
resource "aws_ebs_snapshot" "secops-thehive-attachments-snapshot" {
  volume_id = data.aws_ebs_volume.secops-thehive-attachments-volume.id

  tags = {
    Name = "thehive-attachments-snapshot"
  }
}

# We create a snapshot of the TheHive index volume to base our new index volume upon
# This way we never touch the original / previous EBS index volume
resource "aws_ebs_snapshot" "secops-thehive-index-snapshot" {
  volume_id = data.aws_ebs_volume.secops-thehive-index-volume.id

  tags = {
    Name = "thehive-index-snapshot"
  }
}

# We create a keypair to connect to our TheHive instance
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.secops_key_pair_name
  public_key = var.secops_key_pair_public_key
}

# We create the TheHive instance based on the various variables we have already set
# The cloud-config user data file allows to partition and format the ElasticSearch EBS volume
# and to launch the TheHive initialization script
resource "aws_instance" "thehive-secops" {
  ami           = data.aws_ami.secops_thehive_ami.id
  instance_type = var.secops_ec2_instance_type
  subnet_id = data.aws_subnet.secops-private-subnet-1.id
  vpc_security_group_ids = [data.aws_security_group.secops-sg-ssh.id,data.aws_security_group.secops-sg-thehive.id]
  key_name = aws_key_pair.ec2_key_pair.key_name
  user_data = file("files/th-cloud-config-restore.yaml")
  ebs_block_device {
    device_name = "/dev/sdh"
    snapshot_id = aws_ebs_snapshot.secops-thehive-data-snapshot.id
    volume_type = "gp2"
    delete_on_termination = false
  }   
  ebs_block_device {
    device_name = "/dev/sdi"
    snapshot_id = aws_ebs_snapshot.secops-thehive-attachments-snapshot.id
    volume_type = "gp2"
    delete_on_termination = false
  }   
  ebs_block_device {
    device_name = "/dev/sdj"
    snapshot_id = aws_ebs_snapshot.secops-thehive-index-snapshot.id
    volume_type = "gp2"
    delete_on_termination = false
  }   
  tags = {
    Name = "thehive-secops"
  }
}

# We create a DNS record for the TheHive private IP so that we can easily connect to it through our bastion host
resource "aws_route53_record" "thehive" {
  zone_id = data.aws_route53_zone.secops-vpc-dns-zone.zone_id
  name    = "thehive.${data.aws_route53_zone.secops-vpc-dns-zone.name}"
  type    = "A"
  ttl     = "300"
  allow_overwrite = true
  records = [aws_instance.thehive-secops.private_ip]
}

# We add the newly created instance to the ALB TheHive target group
resource "aws_lb_target_group_attachment" "thehive-secops-alb-tg-attachment" {
  target_group_arn = data.aws_lb_target_group.secops-alb-tg-thehive.arn
  target_id        = aws_instance.thehive-secops.id
  port             = 9000
}