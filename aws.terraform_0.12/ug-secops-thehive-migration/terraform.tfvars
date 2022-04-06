# VPC variables
secops_iam_profile = "secops"
secops_region = "us-east-1"
secops_vpc_name = "secops-vpc"
secops_private_subnet_1_name = "secops-private-subnet-1"
secops_ssh_sg_name = "secops-ssh-sg"
secops_thehive_sg_name = "secops-thehive-sg"
secops_alb_target_group_name_thehive = "secops-alb-thehive-tg"

# TheHive instance type and StrangeBee account number to find latest TheHive AMI
secops_ec2_instance_type = "m5.xlarge"
strangebee_account_number = "339624944083"

# SSH keypair to access TheHive instance
secops_key_pair_name = "thehive-secops-key"
secops_key_pair_public_key = "ssh-rsa AAAAB3NzaC.... user@mydomain.com"

# ID of the existing TheHive EBS data volume to snapshot
secops-thehive-data-volume_id = "vol-012345abc"

# Private VPC DNS zone to create TheHive record into (for easy SSH connection)
secops_r53_private_dns_zone_name = "secops.cloud"