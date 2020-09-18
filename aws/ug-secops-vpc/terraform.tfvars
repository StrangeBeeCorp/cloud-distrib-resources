# VPC variables
secops_iam_profile = "secops"
secops_region = "us-east-1"
secops_az1 = "us-east-1a"
secops_az2 = "us-east-1b"
secops_vpc_cidr = "10.100.0.0/16"
secops_public_subnet_1_cidr = "10.100.10.0/24"
secops_public_subnet_2_cidr = "10.100.11.0/24"
secops_private_subnet_1_cidr = "10.100.20.0/24"
secops_private_subnet_2_cidr = "10.100.21.0/24"

# Application user whitelist to load balancer listener - enable public to open widely
secops_users_cidr = {
    "user1" = "1.2.3.4/32",
#    "public" = "0.0.0.0/0"
}

# Certificate and public DNS records for load balancer
secops_alb_certificate = "arn:aws:acm:us-east-1:123456789:certificate/123fbab3-1234-42fc-1234-f123eac3f994"
secops_r53_public_dns_zone_id = "ZCHANGEME"
secops_r53_thehive_record = "thehive.public.dns.tld"
secops_r53_cortex_record = "cortex.public.dns.tld"

# Private DNS zone creation (will be useful for TheHive to find Cortex and for SSH proxyjump)
secops_r53_private_dns_zone_name = "secops.cloud"

# Bastion host instance type and Canonical account number to find latest Ubuntu AMI
secops_ec2_instance_type = "t2.micro"
canonical_account_number = "099720109477"

# SSH user whitelist to bastion host
secops_ssh_users_cidr = {
#    "admin1" = "1.2.3.4/32",
    "admin2" = "1.2.3.4/32",
#    "admin3" = "1.2.3.0/32"
}

# SSH keypair to access bastion host
secops_key_pair_name = "jumphost-secops-key"
secops_key_pair_public_key = "ssh-rsa AAAAB3NzaC... user@mydomain.com"
