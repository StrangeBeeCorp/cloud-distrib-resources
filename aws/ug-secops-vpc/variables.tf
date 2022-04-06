##################################################
# Global config
##################################################

variable "secops_iam_profile" {
  type = string
  description = "secops IAM profile"
}

variable "secops_region" {
  type = string
  description = "secops AWS Region"
}

variable "canonical_account_number" {
  type = string
  description = "Canonical AWS account number to get AMIs from"
  default     = "099720109477"
}

##################################################
# VPC & Network
##################################################

variable "secops_az1" {
  type = string
  description = "secops AWS availability zone 1"
}

variable "secops_az2" {
  type = string
  description = "secops AWS availability zone 2"
}

variable "secops_vpc_name" {
  type = string
  description = "secops VPC Name"
}

variable "secops_vpc_cidr" {
  type = string
  description = "secops VPC CIDR Block"
}

variable "secops_public_subnet_1_cidr" {
  type = string
  description = "secops public Subnet 1 CIDR"
}

variable "secops_public_subnet_1_name" {
  type = string
  description = "secops public Subnet 1 Name"
}

variable "secops_public_subnet_2_cidr" {
  type = string
  description = "secops public Subnet 2 CIDR"
}

variable "secops_public_subnet_2_name" {
  type = string
  description = "secops public Subnet 2 Name"
}

variable "secops_private_subnet_1_cidr" {
  type = string
  description = "secops private Subnet 1 CIDR"
}

variable "secops_private_subnet_1_name" {
  type = string
  description = "secops private Subnet 1 Name"
}

variable "secops_private_subnet_2_cidr" {
  type = string
  description = "secops private Subnet 2 CIDR"
}

variable "secops_private_subnet_2_name" {
  type = string
  description = "secops private Subnet 2 Name"
}

variable "secops_public_route_table_name" {
  type = string
  description = "secops public route table name"
}

variable "secops_private_route_table_name" {
  type = string
  description = "secops public route table name"
}

variable "secops_igw_name" {
  type = string
  description = "secops internet gateway name"
}

variable "secops_natgw_eip" {
  type = string
  description = "secops nat gateway eip"
}

variable "secops_natgw_name" {
  type = string
  description = "secops nat gateway name"
}

##################################################
# Security Groups
##################################################

variable "secops_public_ssh_sg_name" {
  type = string
  description = "secops public ssh sg name"
}

variable "secops_ssh_users_cidr" {
  type = map(string)
  description = "secops SSH users ingress CIDR"
}

variable "secops_private_ssh_sg_name" {
  type = string
  description = "secops private ssh sg name"
}

variable "secops_public_alb_access_sg_name" {
  type = string
  description = "secops public ALB access sg name"
}

variable "secops_users_cidr" {
  type = map(string)
  description = "secops Users ingress CIDR"
}

##################################################
# Application Load Balancer, ACM certificates & DNS
##################################################

variable "secops_alb_name" {
  type = string
  description = "secops ALB name"
}

variable "secops_r53_private_dns_zone_name" {
  type = string
  description = "secops new private DNS zone name in Route53 for VPC name resolution"
}

variable "secops_r53_public_dns_zone_name" {
  type = string
  description = "secops public DNS zone name in Route53 for internet name resolution"
}

variable "secops_r53_record" {
  type = string
  description = "DNS record for ALB listener in Route53"
}

variable "secops_r53_records_san" {
  type = list(string)
  default = []
  description = "Set of domains that should be SANs in the issued certificate"
}

##################################################
# Instances
##################################################

variable "secops_key_pair_name" {
  type = string
  description = "Keypair name to use to connect to EC2 Instances"
}

variable "secops_key_pair_public_key" {
  type = string
  description = "Keypair public key to use to connect to EC2 Instances"
}

variable "secops_bastion_ec2_instance_type" {
  type = string
  description = "EC2 default instance type to launch"
  default     = "t2.micro"
}

variable "secops_bastion_ec2_instance_name" {
  type = string
  description = "bastion instance name"
}

variable "secops_bastion_ec2_instance_os_name" {
  type = string
  description = "bastion instance EBS system volume name"
}

variable "secops_bastion_eip" {
  type = string
  description = "secops bastion eip"
}


