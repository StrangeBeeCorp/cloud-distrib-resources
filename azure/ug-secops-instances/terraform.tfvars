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
# Application Gateway backend pool names
secops-thehive-backend-pool-name = "secops-thehive-backend-pool"
secops-cortex-backend-pool-name = "secops-cortex-backend-pool"

# TheHive and Cortex instance
secops-th-baseurl = "https://thehive.mydomain.com"
secops-th-computer-name = "secops-thehive5"
secops-th-vm-size = "Standard_D4_v4"
secops-cortex-computer-name = "secops-cortex"
secops-cortex-vm-size = "Standard_D4_v4"
secops-admin-user = "azureuser"
secops-public-key-path = "~/.ssh/id_rsa.pub"

# Image versions
secops-image-th-version = "strangebee/thehive:5.0.14-1"
secops-image-cortex-version = "thehiveproject/cortex:3.1.6-1-withdeps"
secops-image-cassandra-version = "cassandra:4.0.6"
secops-image-elasticsearch-version = "elasticsearch:7.17.6"
secops-image-nginx-version = "nginx:1.23.1"

# Managed OS Disk type - possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS
secops-os-disk-type   = "StandardSSD_LRS"

# Data disks for TheHive and Cortex instances
secops-th-os-disk-name = "secops-thehive-system-disk" 
secops-th-data-disk-name = "secops-thehive-data-disk" 
secops-th-docker-disk-name = "secops-thehive-docker-disk" 
secops-cortex-os-disk-name = "secops-cortex-system-disk" 
secops-cortex-data-disk-name = "secops-cortex-data-disk" 
secops-cortex-docker-disk-name = "secops-cortex-docker-disk" 

# Private zone DNS name
secops-private-zone-name  = "private.mydomain.com"
# Bastion NIC name 
secops-nic-bastion-name = "secops-nic-bastion"
# Cortex NIC name 
secops-nic-cortex-name = "secops-nic-cortex"
# Cortex NSG name 
secops-cortex-nsg-name = "secops-cortex-nsg"

# Overload Azure marketplace product version to use specific version since "latest" is not based on publishing date
# secops-thehive-version = "latest"
secops-thehive-version = "5.0.121"