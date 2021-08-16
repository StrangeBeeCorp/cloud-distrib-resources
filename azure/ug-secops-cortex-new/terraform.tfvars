# Resource group name
secops-resource-group-name = "SecOps"
# Target region
secops-location = "France Central"

## Virtual Network
secops-virtual-network-name = "secops-vnet"
# Subnet names
secops-backend-private-subnet-name = "secops-backend-private-subnet"
# Private network security group name
secops-nic-lan-myNVA-nsg-name = "secops-nic-lan-myNVA-nsg"
# Public network security group name
secops-public-nsg-name = "secops-public-nsg"
# Application Gateway name
secops-appgw-name = "secops-appgw"
# Application Gateway subnet CIDR
secops-appgw-frontend-public-subnet = "10.1.0.0/16"
# Application Gateway cortex backend pool name
secops-cortex-backend-pool-name = "secops-cortex-backend-pool"

# Cortex instance
secops-computer-name = "secops-cortex3"
secops-vm-size = "Standard_D4s_v4"
secops-admin-user = "ubuntu"
secops-public-key-path = "~/.ssh/id_rsa.pub"
secops-data-disk-name = "secops-cortex3-data-disk"
secops-data-disk-size = "32"
secops-docker-disk-name = "secops-cortex3-docker-disk"
secops-docker-disk-size = "16"
# Managed OS Disk type - possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS
secops-data-disk-type = "Premium_LRS"
secops-os-disk-type   = "Premium_LRS"

# Private zone DNS name
secops-private-zone-name  = "private.mydomain.com"
# Bastion NIC name 
secops-nic-bastion-name = "secops-nic-bastion"
