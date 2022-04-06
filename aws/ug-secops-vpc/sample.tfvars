# Global config
secops_iam_profile = "profilename"
secops_region = "us-east-1"

# VPC & Network
secops_az1 = "us-east-1a"
secops_az2 = "us-east-1b"
secops_vpc_name = "secops0"
secops_vpc_cidr = "10.1.0.0/16"
secops_public_subnet_1_cidr = "10.1.1.0/24"
secops_public_subnet_1_name = "secops0-public-subnet-1"
secops_public_subnet_2_cidr = "10.1.2.0/24"
secops_public_subnet_2_name = "secops0-public-subnet-2"
secops_private_subnet_1_cidr = "10.1.101.0/24"
secops_private_subnet_1_name = "secops0-private-subnet-1"
secops_private_subnet_2_cidr = "10.1.102.0/24"
secops_private_subnet_2_name = "secops0-private-subnet-2"
secops_public_route_table_name = "secops0-public-route-table"
secops_private_route_table_name = "secops0-private-route-table"
secops_igw_name = "secops0-igw"
secops_natgw_eip = "secops0-natgw-eip"
secops_natgw_name = "secops0-natgw"

# Security Groups
secops_public_ssh_sg_name = "secops0-public-ssh-sg"
secops_ssh_users_cidr = {
#    "any" = "0.0.0.0/0",
#    "user1" = "1.2.3.4/32",
#    "block1" = "1.2.3.0/24"
}
secops_private_ssh_sg_name = "secops0-private-ssh-sg"
secops_public_alb_access_sg_name = "secops0-public-alb-access-sg"
secops_users_cidr = {
#    "any" = "0.0.0.0/0",
#    "user1" = "1.2.3.4/32",
#    "block1" = "1.2.3.0/24"
}

# Application Load Balancer, ACM certificates & DNS
secops_alb_name = "secops0-alb"
secops_r53_private_dns_zone_name = "secops0.privatevpc"
secops_r53_public_dns_zone_name = "mydomain.com"
secops_r53_record = "secops0.mydomain.com"
secops_r53_records_san = [
    "thehive.mydomain.com",
    "cortex.mydomain.com"
]

# Bastion instance configuration
secops_key_pair_name = "jumphost-secops-key"
secops_key_pair_public_key = "ssh-rsa AAfullpublickey= admin@secops"
secops_bastion_ec2_instance_type = "t3a.micro"
secops_bastion_ec2_instance_name = "secops0-bastion-host"
secops_bastion_ec2_instance_os_name = "secops0-bastion-host-system"
secops_bastion_eip = "secops0-bastion-eip"
