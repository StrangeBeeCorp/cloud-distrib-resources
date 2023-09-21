# Resource group name
secops-resource-group-name = "customer-resource-group"
# Target region
secops-location = "France Central"

## Virtual Network
secops-virtual-network-name = "customer-vnet"
# Subnet names
secops-backend-private-subnet-name = "customer-backend-private-subnet"
# Private network security group name
secops-nic-lan-myNVA-nsg-name = "secops-nic-lan-myNVA-nsg"
# Public network security group name
secops-public-nsg-name = "secops-public-nsg"
# Application Gateway name
secops-appgw-name = "secops-appgw"
# Application Gateway subnet CIDR
secops-appgw-frontend-public-subnet = "10.1.0.0/16"
# Application Gateway thehive backend pool name
secops-thehive-backend-pool-name = "secops-thehive-backend-pool"

# TheHive instance
secops-computer-name = "customer-thehive4"
secops-vm-size = "Standard_D2s_v4"
secops-admin-user = "ubuntu"
secops-public-key-path = "~/.ssh/id_rsa.pub"
secops-data-disk-name = "customer-thehive4-data-disk"
secops-storage-disk-name = "customer-thehive4-storage-disk"
secops-index-disk-name = "customer-thehive4-index-disk"
# Managed OS Disk type - possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS
secops-data-disk-type = "Premium_LRS"
secops-os-disk-type   = "Premium_LRS"

# Private zone DNS name
secops-private-zone-name  = "strangebee.cloud"
# Bastion NIC name 
secops-nic-bastion-name = "secops-nic-bastion"

## Enable cortex connection ? 
# Possible values are either true or false
enable_cortex_connection = true
# If enable_cortex_connection is set to true (cortex is already implemented), specify Cortex NIC name & NSG name
# Cortex NIC name 
secops-nic-cortex-name = "secops-nic-cortex"
# Cortex NSG name 
secops-cortex-nsg-name = "secops-cortex-nsg"

