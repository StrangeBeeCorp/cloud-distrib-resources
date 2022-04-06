variable "secops_region" {
  type = string
  description = "AWS Region"
}

variable "secops_iam_profile" {
  type = string
  description = "secops IAM profile"
}

variable "strangebee_account_number" {
  type = string
  description = "StrangeBee AWS account number to get AMIs from"
  default     = "339624944083"
}

variable "secops_vpc_name" {
  type = string
  description = "Name of secops VPC"
}

variable "secops_private_subnet_1_name" {
  type = string
  description = "Name of target subnet to deploy instances"
}

variable "secops_ssh_sg_name" {
  type = string
  description = "Name of secops SSH security group"
}

variable "secops_cortex_sg_name" {
  type = string
  description = "Name of secops Cortex security group"
}

variable "secops_alb_target_group_name_cortex" {
  type = string
  description = "Name of Cortex ALB target group"
}

variable "secops_ec2_instance_type" {
  type = string
  description = "EC2 default instance type to launch"
  default     = "m5.xlarge"
}

variable "secops_key_pair_name" {
  type = string
  description = "Keypair name to use to connect to EC2 Instances"
}

variable "secops_key_pair_public_key" {
  type = string
  description = "Keypair public key to use to connect to EC2 Instances"
}

variable "secops_r53_private_dns_zone_name" {
  type = string
  description = "secops new private DNS zone name in Route53 for VPC name resolution"
}

variable "secops-cortex-data-volume_id" {
  type = string
  description = "ID of existing Cortex EBS data volume to snapshot"
}

variable "secops-cortex-docker-volume_id" {
  type = string
  description = "ID of existing Cortex EBS Docker volume to snapshot"
}