# Store credentials in ~/.aws/credentials and declare invalid default profile to avoid mistakes
# [default]
# aws_access_key_id=AK-INVALID
# aws_secret_access_key=INVALIDKEY

# [secops]
# aws_access_key_id=AKIAIOSFODNN7EXAMPLE
# aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
provider "aws" {
  version = "~> 3.0"
  profile = var.secops_iam_profile
  region  = var.secops_region
}

# We must locate some existing resources to set the run context for the TheHive instance
# We look for VPC based on its name so that we can refer to its ID later on
data "aws_vpc" "secops-vpc" {
  filter {
    name   = "tag:Name"
    values = [var.secops_vpc_name]
  }
}

# We look for the SSH security group based on its name so that we can refer to its ID later on
data "aws_security_group" "secops-sg-ssh" {
  filter {
    name   = "tag:Name"
    values = [var.secops_ssh_sg_name]
  }
}

# We look for the TheHive security group based on its name so that we can refer to its ID later on
data "aws_security_group" "secops-sg-thehive" {
  filter {
    name   = "tag:Name"
    values = [var.secops_thehive_sg_name]
  }
}

# We look for our target subnet based on its name so that we can refer to its ID later on
data "aws_subnet" "secops-private-subnet-1" {
  filter {
    name   = "tag:Name"
    values = [var.secops_private_subnet_1_name]
  }
}

# We look for the latest TheHive AMI based on search filters so that we can refer to its ID later on
data "aws_ami" "secops_thehive_ami" {
  most_recent = true
  owners = [var.strangebee_account_number]

  filter {
    name   = "name"
    values = ["TheHive4_*"]
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

# We look for the TheHive ALB target group based on its name so that we can refer to its ID later on
data "aws_lb_target_group" "secops-alb-tg-thehive" {
  name = var.secops_alb_target_group_name_thehive
}

# We look for the private Route53 DNS zone based on its name so that we can refer to its ID later on
data "aws_route53_zone" "secops-vpc-dns-zone" {
  name         = var.secops_r53_private_dns_zone_name
  private_zone = true
}
