# We look for the latest Ubuntu AMI based on search filters so that we can refer to its ID later on
data "aws_ami" "secops_ubuntu_ami" {
  most_recent = true
  owners = [var.canonical_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-????????"]
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

# We create a keypair to connect to our bastion host instance
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.secops_key_pair_name
  public_key = var.secops_key_pair_public_key
}

# We create the bastion host instance based on the various variables we have already set
resource "aws_instance" "bastion-host-secops" {
  ami           = data.aws_ami.secops_ubuntu_ami.id
  instance_type = var.secops_ec2_instance_type
  subnet_id = aws_subnet.secops-public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.secops-public-ssh-sg.id]
  key_name = aws_key_pair.ec2_key_pair.key_name
#  user_data = file("files/cortex-cloud-config-new.yaml")
  
  tags = {
    Name = "bastion-host-secops"
  }
}

# We allocate a public IP to the bastion host instance
resource "aws_eip" "bastion-host-secops-eip" {
  instance = aws_instance.bastion-host-secops.id
  vpc      = true
}
