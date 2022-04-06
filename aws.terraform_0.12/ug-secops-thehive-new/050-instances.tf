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
  user_data = file("files/th-cloud-config-new.yaml")
  
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