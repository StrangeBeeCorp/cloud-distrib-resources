variable "secops_region" {
  type = string
  description = "secops AWS Region"
  default     = "us-east-1"
}

variable "secops_az1" {
  type = string
  description = "secops AWS availability zone 1"
}

variable "secops_az2" {
  type = string
  description = "secops AWS availability zone 2"
}

variable "secops_iam_profile" {
  type = string
  description = "secops IAM profile"
}

variable "secops_vpc_cidr" {
  type = string
  description = "secops VPC CIDR Block"
}

variable "secops_public_subnet_1_cidr" {
  type = string
  description = "secops public Subnet 1 CIDR"
}

variable "secops_public_subnet_2_cidr" {
  type = string
  description = "secops public Subnet 2 CIDR"
}

variable "secops_private_subnet_1_cidr" {
  type = string
  description = "secops private Subnet 1 CIDR"
}

variable "secops_private_subnet_2_cidr" {
  type = string
  description = "secops private Subnet 2 CIDR"
}

variable "secops_ssh_users_cidr" {
  type = map(string)
  description = "secops SSH users ingress CIDR"
}

variable "secops_users_cidr" {
  type = map(string)
  description = "secops Users ingress CIDR"
}

variable "secops_alb_certificate" {
  type = string
  description = "Pre-existing ACM-managed certificate ARN to use for ALB"
}

variable "secops_r53_private_dns_zone_name" {
  type = string
  description = "secops new private DNS zone name in Route53 for VPC name resolution"
}

variable "secops_r53_public_dns_zone_id" {
  type = string
  description = "secops pre-existing public DNS zone ID in Route53 for ALB"
}

variable "secops_r53_thehive_record" {
  type = string
  description = "TheHive build DNS record for ALB listener in Route53"
}

variable "secops_r53_cortex_record" {
  type = string
  description = "Cortex build DNS record for ALB listener in Route53"
}

variable "secops_key_pair_name" {
  type = string
  description = "Keypair name to use to connect to EC2 Instances"
}

variable "secops_key_pair_public_key" {
  type = string
  description = "Keypair public key to use to connect to EC2 Instances"
}

variable "canonical_account_number" {
  type = string
  description = "Canonical AWS account number to get AMIs from"
  default     = "099720109477"
}

variable "secops_ec2_instance_type" {
  type = string
  description = "EC2 default instance type to launch"
  default     = "t2.micro"
}