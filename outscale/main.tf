#######################################
### NEW SECOPS ENVIRONMENT CREATION ###
#######################################

# IMPORTANT NOTE: For this Terraform code to work, you must include either the "instances-init-thehive-cortex.tf" 
# or "instances-restore-thehive-cortex.tf" from the _use-cases subfolder. 

#####################
### VPC & NETWORK ###
#####################

# Check https://wiki.outscale.net/pages/viewpage.action?pageId=43061554 for more information on subnet security
# By default, thanks to a network enhancement, instances within a same subnet 
# can communicate with one another without any security group rules required. 
# This enables to reduce overall latency between two instances and avoid issues for specific protocols, 
# like those used by Microsoft Windows. If you want to have further security between two instances 
# (for example, one in a DMZ and one in an internal network), place them in different subnets or disable this feature.
# You can disable this feature by adding, before creating subnets, the osc.fcu.enable_lan_security_groups tag key 
# to your VPC using the method described in Adding or Removing Tags. The value you specify for this tag is not taken 
# into account. Once this tag is set, you then need to add appropriate rules to the security groups of your 
# instances placed in the same subnet to allow them to communicate with one another.
# This behavior cannot be modified by adding or removing this tag once you create one or more subnets in the VPC.

# We create a brand new "SecOps" VPC and subnets with explicit subnet security
resource "outscale_net" "secops-vpc" {
  ip_range = var.secops_vpc_cidr
  tenancy  = "default"

  tags  {
    key   = "osc.fcu.enable_lan_security_groups"
    value = "true"
  }

}

# We create two public subnets for our bastion host, NAT Gateway, Internet Gateway
# This will also be used for the ALB target groups
resource "outscale_subnet" "secops-public-subnet-1" {
  net_id = outscale_net.secops-vpc.net_id
  ip_range = var.secops_public_subnet_1_cidr
}

resource "outscale_subnet" "secops-public-subnet-2" {
  net_id = outscale_net.secops-vpc.net_id
  ip_range = var.secops_public_subnet_2_cidr
}

# We create two private subnets to host our instances
resource "outscale_subnet" "secops-private-subnet-1" {
  net_id = outscale_net.secops-vpc.net_id
  ip_range = var.secops_private_subnet_1_cidr
}

resource "outscale_subnet" "secops-private-subnet-2" {
  net_id = outscale_net.secops-vpc.net_id
  ip_range = var.secops_private_subnet_2_cidr
}

# We create a route table for our public subnets to be allowed to use the Internet Gateway
# and associate the route table with its subnets
resource "outscale_route_table" "secops-public-route-table" {
  net_id = outscale_net.secops-vpc.net_id
}

resource "outscale_route_table_link" "secops-public-subnet-1-association" {
    subnet_id      = outscale_subnet.secops-public-subnet-1.subnet_id
    route_table_id = outscale_route_table.secops-public-route-table.id
}

resource "outscale_route_table_link" "secops-public-subnet-2-association" {
    subnet_id      = outscale_subnet.secops-public-subnet-2.subnet_id
    route_table_id = outscale_route_table.secops-public-route-table.id
}

# We create a route table for our private subnets to be allowed to reach the public subnet 
# to use the NAT Gateway and associate the route table with both subnets
resource "outscale_route_table" "secops-private-route-table" {
  net_id = outscale_net.secops-vpc.net_id
}

resource "outscale_route_table_link" "secops-private-subnet-1-association" {
    subnet_id      = outscale_subnet.secops-private-subnet-1.subnet_id
    route_table_id = outscale_route_table.secops-private-route-table.id
}

resource "outscale_route_table_link" "secops-private-subnet-2-association" {
    subnet_id      = outscale_subnet.secops-private-subnet-2.subnet_id
    route_table_id = outscale_route_table.secops-private-route-table.id
}


# We create the Internet Gateway and add a route to it in the public route table
resource "outscale_internet_service" "secops-vpc-igw" {
}

resource "outscale_internet_service_link" "secops-vpc-igw-association" {
  net_id = outscale_net.secops-vpc.net_id
  internet_service_id = outscale_internet_service.secops-vpc-igw.id
}

resource "outscale_route" "secops-private-internet-gw-route" {
  destination_ip_range = "0.0.0.0/0"
  gateway_id           = outscale_internet_service.secops-vpc-igw.internet_service_id
  route_table_id       = outscale_route_table.secops-public-route-table.route_table_id
}

# We create a NAT Gateway within public subnet 1
resource "outscale_public_ip" "secops-nat-gw-eip" {
}

resource "outscale_nat_service" "secops-nat-gw" {
  subnet_id    = outscale_subnet.secops-public-subnet-1.subnet_id
  public_ip_id = outscale_public_ip.secops-nat-gw-eip.public_ip_id
}

# We create a route to allow the private subnets to reach the Internet through 
# the NAT Gateway in the public subnet 
resource "outscale_route" "secops-public-subnet-nat-gw-route" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id       = outscale_nat_service.secops-nat-gw.nat_service_id
  route_table_id       = outscale_route_table.secops-private-route-table.route_table_id
}

# We create the public IP for the bastion host
resource "outscale_public_ip" "secops-bastion-host-eip" {
}

#######################
### SECURITY GROUPS ###
#######################

# We create a security group to allow SSH access to our bastion / router host in the public subnet
resource "outscale_security_group" "secops-public-ssh-sg" {
  description         = "SecOps public SSH access to jumphost"
  security_group_name = var.secops_public_ssh_sg_name
  net_id = outscale_net.secops-vpc.net_id
}

# We create the ingress rule to allow public SSH access from a whitelist in a variable
resource "outscale_security_group_rule" "secops-public-ssh-sg-allow-ssh" {
  for_each        = var.secops_ssh_users_cidr
  flow              = "Inbound"
  security_group_id = outscale_security_group.secops-public-ssh-sg.security_group_id
  from_port_range   = "22"
  to_port_range     = "22"
  ip_protocol       = "tcp"
  ip_range          = each.value
}

# We create an egress rule to allow outgoing SSH traffic from the bastion / router host to TheHive and Cortex instances
resource "outscale_security_group_rule" "secops-public-ssh-sg-allow-egress" {
  flow              = "Outbound"
  security_group_id = outscale_security_group.secops-public-ssh-sg.security_group_id
    rules {
     from_port_range   = "22"
     to_port_range     = "22"
     ip_protocol       = "tcp"
     security_groups_members {
        account_id          =  "188126795143"
        security_group_id = outscale_security_group.secops-ssh-sg.security_group_id
       }
    }
}

# We create a security group to allow SSH access to our instances in the private subnets from the bastion / router host
resource "outscale_security_group" "secops-ssh-sg" {
  description         = "SecOps SSH access to private instances"
  security_group_name = var.secops_private_ssh_sg_name
  net_id = outscale_net.secops-vpc.net_id
}

# We create the ingress rule to allow public SSH access from the bastion / router host
resource "outscale_security_group_rule" "secops-ssh-sg-allow-ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.secops-ssh-sg.security_group_id
    rules {
     from_port_range   = "22"
     to_port_range     = "22"
     ip_protocol       = "tcp"
     security_groups_members {
        account_id          =  "188126795143"
        security_group_id = outscale_security_group.secops-public-ssh-sg.security_group_id
      }
    }
}

# # We create an egress rule to allow all outgoing traffic from our instances (customize this to your needs / context)
# resource "outscale_security_group_rule" "secops-ssh-sg-allow-egress" {
#   flow              = "Outbound"
#   security_group_id = outscale_security_group.secops-ssh-sg.security_group_id
#   from_port_range   = "0"
#   to_port_range     = "0"
#   ip_protocol       = "tcp"
#   ip_range          = "0.0.0.0/0"
# }

# We create a security group to allow http access to our TheHive instance in the private subnet
# This is required to issue and renew Let's Encrypt certificates only, 
# the applications themselves are only available on port 443/https.
resource "outscale_security_group" "secops-private-th-sg" {
  description         = "SecOps private access to TheHive"
  security_group_name = var.secops_private_th_sg_name
  net_id = outscale_net.secops-vpc.net_id
}

# We create a security group to allow http access to our Cortex instance in the public subnet (for DEV only)
resource "outscale_security_group" "secops-private-cortex-sg" {
  description         = "SecOps private access to Cortex"
  security_group_name = var.secops_private_cortex_sg_name
  net_id = outscale_net.secops-vpc.net_id
}


# We create the ingress rule to allow Cortex access from TheHive
resource "outscale_security_group_rule" "secops-cortex-sg-allow-th" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.secops-private-cortex-sg.security_group_id
    rules {
     from_port_range   = "9001"
     to_port_range     = "9001"
     ip_protocol       = "tcp"
     security_groups_members {
        account_id          =  "188126795143"
        security_group_id = outscale_security_group.secops-private-th-sg.security_group_id
      }
    }
}

### TheHive Router rules ###
# We create a security group to allow Web access to our bastion / router host in the public subnet
resource "outscale_security_group" "secops-rp-access-sg" {
  description         = "SecOps public Web access to router"
  security_group_name = var.secops_public_web_sg_name
  net_id = outscale_net.secops-vpc.net_id
}

# We create the ingress rule to allow public Web (http) access from a whitelist in a variable
# This will probably result in ANY access to port 80 since it's required for Let's Encrypt verification
resource "outscale_security_group_rule" "secops-rp-access-sg-allow-http" {
  for_each        = var.secops_http_users_cidr
  flow              = "Inbound"
  security_group_id = outscale_security_group.secops-rp-access-sg.security_group_id
  from_port_range   = "80"
  to_port_range     = "80"
  ip_protocol       = "tcp"
  ip_range          = each.value
}

# We create the ingress rule to allow public Web (https) access from a whitelist in a variable
resource "outscale_security_group_rule" "secops-rp-access-sg-allow-https" {
  for_each        = var.secops_https_users_cidr
  flow              = "Inbound"
  security_group_id = outscale_security_group.secops-rp-access-sg.security_group_id
  from_port_range   = "443"
  to_port_range     = "443"
  ip_protocol       = "tcp"
  ip_range          = each.value
}

# We create the ingress rule to allow TheHive access from the bastion / router host
resource "outscale_security_group_rule" "secops-th-sg-allow-router" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.secops-private-th-sg.security_group_id
    rules {
     from_port_range   = "9000"
     to_port_range     = "9000"
     ip_protocol       = "tcp"
     security_groups_members {
        account_id          =  "188126795143"
        security_group_id = outscale_security_group.secops-rp-access-sg.security_group_id
      }
    }
}

# We create the ingress rule to allow Cortex access from the bastion / router host
resource "outscale_security_group_rule" "secops-cortex-sg-allow-router" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.secops-private-cortex-sg.security_group_id
    rules {
     from_port_range   = "9001"
     to_port_range     = "9001"
     ip_protocol       = "tcp"
     security_groups_members {
        account_id          =  "188126795143"
        security_group_id = outscale_security_group.secops-rp-access-sg.security_group_id
      }
    }
}

######################################
### BASTION / ROUTER HOST CREATION ###
######################################

######################################
### GET DATA TO EXISTING RESOURCES ###
######################################

# We look for the latest TheHive Router OMI based on search filters so that we can refer to its ID later on
data "outscale_image" "secops_router_omi" {
  filter {
    name   = "image_names"
    values = [var.secops_bastion_omi_name]
  }
}

########################
### ROUTER INSTANCE  ###
########################

# We create the bastion host instance
resource "outscale_vm" "bastion-host-secops" {
  image_id                 = data.outscale_image.secops_router_omi.image_id
  vm_type                  = var.secops_bastion_ec2_instance_type
  keypair_name             = var.secops_key_pair_name
  subnet_id                = outscale_subnet.secops-public-subnet-1.subnet_id
  security_group_ids       = [outscale_security_group.secops-public-ssh-sg.security_group_id,outscale_security_group.secops-rp-access-sg.security_group_id]    
  user_data = base64encode(templatefile("files/bastion-cloud-config-new.tpl", {
    caddydomain = var.secops_bastion_caddy_domain,
    caddyemail = var.secops_bastion_caddy_email,
    caddythehivehost = outscale_vm.secops-th4-instance.private_ip,
    caddycortexhost = outscale_vm.secops-cortex3-instance.private_ip
  }))
}

resource "outscale_public_ip_link" "secops-bastion-host-eip-association" {
    vm_id     = outscale_vm.bastion-host-secops.vm_id
    public_ip = outscale_public_ip.secops-bastion-host-eip.public_ip
}
