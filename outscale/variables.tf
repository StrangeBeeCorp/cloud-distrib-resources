# VPC variables
variable "secops_region" {
  type = string
  description = "secops Outscale Region"
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

variable "secops_natgw_eip" {
  type = string
  description = "secops nat gateway eip"
}

variable "secops_natgw_name" {
  type = string
  description = "secops nat gateway name"
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

# Security groups variables
variable "secops_public_ssh_sg_name" {
  type = string
  description = "secops public ssh sg name"
}

variable "secops_private_ssh_sg_name" {
  type = string
  description = "secops private ssh sg name"
}

variable "secops_public_web_sg_name" {
  type = string
  description = "secops public web sg name"
}

variable "secops_private_th_sg_name" {
  type = string
  description = "secops private TheHive sg name"
}

variable "secops_private_cortex_sg_name" {
  type = string
  description = "secops private Cortex sg name"
}

variable "secops_ssh_users_cidr" {
  type = map(string)
  description = "secops SSH users ingress CIDR"
}

variable "secops_http_users_cidr" {
  type = map(string)
  description = "secops Web users (http) ingress CIDR"
}

variable "secops_https_users_cidr" {
  type = map(string)
  description = "secops Web users (https ingress CIDR"
}

# Instances variables
variable "secops_key_pair_name" {
  type = string
  description = "Keypair name to use to connect to EC2 Instances"
}

variable "secops_bastion_omi_name" {
  type = string
  description = "OMI name for Bastion host"
}

variable "secops_bastion_ec2_instance_type" {
  type = string
  description = "EC2 default instance type to launch"
}

variable "secops_bastion_ec2_instance_name" {
  type = string
  description = "bastion instance name"
}

variable "secops_thehive_omi_name" {
  type = string
  description = "OMI name for TheHive instance"
}

variable "secops_thehive_ec2_instance_type" {
  type = string
  description = "EC2 default instance type to launch"
}

variable "secops_thehive_ec2_instance_name" {
  type = string
  description = "TheHive instance name"
}

variable "secops_cortex_omi_name" {
  type = string
  description = "OMI name for Cortex instance"
}

variable "secops_cortex_ec2_instance_type" {
  type = string
  description = "EC2 default instance type to launch"
}

variable "secops_cortex_ec2_instance_name" {
  type = string
  description = "TheHive instance name"
}

variable "secops_bastion_eip" {
  type = string
  description = "secops bastion eip"
}

variable "secops_thehive_eip" {
  type = string
  description = "secops thehive eip"
}

variable "secops_cortex_eip" {
  type = string
  description = "secops cortex eip"
}

variable "secops_bastion_caddy_domain" {
  type = string
  description = "Caddy domain"
}

variable "secops_bastion_caddy_email" {
  type = string
  description = "Caddy email"
}

variable "secops_thehive_path_pattern" {
  type = string
  description = "Http context path for TheHive"
}

variable "secops_cortex_path_pattern" {
  type = string
  description = "Http context path for Cortex"
}

# Instances variables for upgrade / restore of TheHive and Cortex instances
variable "secops_thehive_data_snapshot_desc" {
  type = string
  description = "TheHive data volume snapshot name"
}

variable "secops_thehive_storage_snapshot_desc" {
  type = string
  description = "TheHive storage volume snapshot name"
}

variable "secops_thehive_index_snapshot_desc" {
  type = string
  description = "TheHive index volume snapshot name"
}

variable "secops_cortex_data_snapshot_desc" {
  type = string
  description = "Cortex data volume snapshot name"
}

variable "secops_cortex_docker_snapshot_desc" {
  type = string
  description = "Cortex Docker volume snapshot name"
}