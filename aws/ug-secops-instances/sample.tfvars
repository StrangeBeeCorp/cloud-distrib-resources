# Global config
secops_iam_profile = "profilename"
secops_region = "us-east-1"

# Network
secops_vpc_name = "secops0"
secops_private-subnet-1_name = "secops0-private-subnet-1"
secops_alb_name = "secops0-alb"
secops_thehive_tg_name = "secops0-alb-thehive-tg"
secops_cortex_tg_name = "secops0-alb-cortex-tg"
secops_vpc-dns-zone-name = "secops0.privatevpc"
secops_thehive_dns-record = "thehive"
secops_cortex_dns-record = "cortex"

# Security Groups
secops_ssh-sg_name = "secops0-private-ssh-sg"
secops_public_alb_access_sg_name = "secops0-public-alb-access-sg"
secops_thehive_sg_name = "secops0-thehive-sg"
secops_cortex_sg_name = "secops0-cortex-sg"

# Instances
secops_thehive_instance_name = "secops0-thehive"
secops_cortex_instance_name = "secops0-cortex"
secops_key_pair_name = "instances-secops-key"
secops_key_pair_public_key = "ssh-rsa AAfullpublickey= admin@secops"

# Config vars
secops_thehive_init = true # true = empty database, false = restore existing data
secops_cortex_init = true # true = empty database, false = restore existing data
secops_instance-type_thehive = "m5.xlarge"
secops_instance-type_cortex = "m5.xlarge"
secops_thehive-ami-name = "TheHive5-ES_*" 
secops_cortex-ami-name = "Cortex3_*" 
secops_thehive_data-rpo = "*"
secops_cortex_data-rpo = "*"
secops_thehive_instance_os_volume_size = "10"
secops_thehive_instance_data_volume_size = "20"
secops_thehive_instance_attachments_volume_size = "10"
secops_thehive_instance_index_volume_size = "5"
secops_cortex_instance_os_volume_size = "10"
secops_cortex_instance_data_volume_size = "30"
secops_cortex_instance_docker_volume_size = "20"
