# VPC variables
secops_region = "eu-west-2"
secops_vpc_name = "secops-vpc"
secops_vpc_cidr = "10.1.0.0/16"
secops_public_subnet_1_cidr = "10.1.1.0/24"
secops_public_subnet_1_name = "secops-public-subnet-1"
secops_public_subnet_2_cidr = "10.1.2.0/24"
secops_public_subnet_2_name = "secops-public-subnet-2"
secops_private_subnet_1_cidr = "10.1.101.0/24"
secops_private_subnet_1_name = "secops-private-subnet-1"
secops_private_subnet_2_cidr = "10.1.102.0/24"
secops_private_subnet_2_name = "secops-private-subnet-2"
secops_natgw_eip = "secops-natgw-eip"
secops_natgw_name = "secops-natgw"
secops_public_route_table_name = "secops-public-route-table"
secops_private_route_table_name = "secops-private-route-table"
secops_igw_name = "secops-igw"

# Security groups variables
secops_public_ssh_sg_name = "secops-public-ssh-sg"
secops_private_ssh_sg_name = "secops-private-ssh-sg"
secops_public_web_sg_name = "secops-rp-access-sg"
secops_private_th_sg_name = "secops-thehive-sg"
secops_private_cortex_sg_name = "secops-cortex-sg"
secops_ssh_users_cidr = {
    "user1" = "1.2.3.4/32",
    "block1" = "5.6.7.8/28",
}
secops_http_users_cidr = {
    "any" = "0.0.0.0/0",  ## This is mandatory for Let's Encrypt to issue and renew certificates
}
secops_https_users_cidr = {
    "user1" = "1.2.3.4/32",
    "block1" = "5.6.7.8/28",
}

# Instances variables
secops_key_pair_name = "secops-key"
secops_bastion_omi_name = "TheHiveRouter1_*"
secops_bastion_ec2_instance_type = "tinav5.c2r4p2"
secops_bastion_ec2_instance_name = "secops-bastion-host"
secops_thehive_ec2_instance_type = "m5.large"
secops_thehive_omi_name = "TheHive4_*"
secops_thehive_ec2_instance_name = "secops-thehive"
secops_cortex_omi_name = "Cortex3_*"
secops_cortex_ec2_instance_type = "m5.large"
secops_cortex_ec2_instance_name = "secops-cortex"
secops_bastion_eip = "secops-bastion-eip"
secops_thehive_eip = "secops-thehive-eip"
secops_cortex_eip = "secops-cortex-eip"
secops_bastion_caddy_domain = "my.domain.com"
secops_bastion_caddy_email = "admin@my.domain.com"
secops_thehive_path_pattern = "/thehive"
secops_cortex_path_pattern = "/cortex"

# Instances variables for upgrade / restore of TheHive and Cortex instances
secops_thehive_data_snapshot_desc = "TH-DATA"
secops_thehive_storage_snapshot_desc = "TH-STORAGE"
secops_thehive_index_snapshot_desc = "TH-INDEX"
secops_cortex_data_snapshot_desc = "CORTEX-DATA"
secops_cortex_docker_snapshot_desc = "CORTEX-DOCKER"
