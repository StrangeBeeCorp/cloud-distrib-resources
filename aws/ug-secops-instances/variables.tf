##################################################
# Global config
##################################################

variable "secops_iam_profile" {
  type = string
  description = "secops IAM profile"
}

variable "secops_region" {
  type = string
  description = "AWS Region hosting the VPC"
}

variable "strangebee_account_number" {
  type = string
  default = "679593333241"
  description = "StrangeBee AWS account number to get AMIs from"
}


##################################################
# Network
##################################################

variable "secops_vpc_name" {
  type = string
  description = "Name of destination VPC"
}

variable "secops_private-subnet-1_name" {
  type = string
  description = "Name of instance destination subnet"
}

variable "secops_alb_name" {
  type = string
  description = "secops ALB name"
}

variable "secops_thehive_tg_name" {
  type = string
  description = "secops TheHive Target Group name"
}

variable "secops_cortex_tg_name" {
  type = string
  description = "secops Cortex Target Group name"
}

variable "secops_vpc-dns-zone-name" {
  type = string
  description = "Name of private VPC DNS zone"
}

variable "secops_thehive_dns-record" {
  type = string
  description = "TheHive host record in private VPC DNS zone"
}

variable "secops_cortex_dns-record" {
  type = string
  description = "Cortex host record in private VPC DNS zone"
}

##################################################
# Security Groups
##################################################

variable "secops_ssh-sg_name" {
  type = string
  description = "Name of security group for SSH access"
}

variable "secops_public_alb_access_sg_name" {
  type = string
  description = "secops public ALB access sg name"
}

variable "secops_thehive_sg_name" {
  type = string
  description = "secops TheHive Security Group name"
}

variable "secops_cortex_sg_name" {
  type = string
  description = "secops Cortex Security Group name"
}

##################################################
# Instances
##################################################

variable "secops_thehive_instance_name" {
  type = string
  description = "TheHive instance name"
}

variable "secops_cortex_instance_name" {
  type = string
  description = "Cortex instance name"
}

variable "secops_key_pair_name" {
  type = string
  description = "Keypair name to use to connect to EC2 Instances"
}

variable "secops_key_pair_public_key" {
  type = string
  description = "Keypair public key to use to connect to EC2 Instances"
}

##################################################
# Config vars
##################################################

variable "secops_thehive_init" {
  type = bool
  description = "Is the SECOPS environment in init phase - TheHive instance"
}

variable "secops_cortex_init" {
  type = bool
  description = "Is the SECOPS environment in init phase - Cortex instance"
}

variable "secops_instance-type_thehive" {
  type = string
  description = "EC2 instance type for TheHive capacity reservation"
}

variable "secops_instance-type_cortex" {
  type = string
  description = "EC2 instance type for Cortex capacity reservation"
}

variable "secops_thehive-ami-name" { 
  type = string
  description = "TheHive AMI name / prefix"
}

variable "secops_cortex-ami-name" { 
  type = string
  description = "Cortex AMI name / prefix"
}

variable "secops_thehive_instance_os_volume_size" {
  type = string
  description = "TheHive instance EBS OS volume size"
}

variable "secops_thehive_instance_data_volume_size" {
  type = string
  description = "TheHive instance EBS data volume size"
}

variable "secops_thehive_instance_attachments_volume_size" {
  type = string
  description = "TheHive instance EBS attachments volume size"
}

variable "secops_thehive_instance_index_volume_size" {
  type = string
  description = "TheHive instance EBS index volume size"
}

variable "secops_cortex_instance_os_volume_size" {
  type = string
  description = "Cortex instance EBS OS volume size"
}

variable "secops_cortex_instance_data_volume_size" {
  type = string
  description = "Cortex instance EBS data volume size"
}

variable "secops_cortex_instance_docker_volume_size" {
  type = string
  description = "Cortex instance EBS Docker volume size"
}
