# Resource group name
secops-resource-group-name = "customer-resource-group"
secops-dns-resource-group-name = "customer-resource-group"
# Target region
secops-location = "France Central"

## Virtual Network
secops-virtual-network-name = "customer-vnet"
# Subnet names
secops-appgw-frontend-public-subnet-name = "customer-appgw-frontend-public-subnet"
secops-backend-private-subnet-name = "customer-backend-private-subnet"
secops-public-subnet-name = "customer-public-subnet"
# Subnets CIDRs
secops-vnet = "10.0.0.0/8"
secops-appgw-frontend-public-subnet = "10.1.0.0/16"
secops-backend-private-subnet = "10.2.0.0/16"
secops-public-subnet = "10.3.0.0/16"
# Public IPs
secops-bastion-public-ip-name = "customer-bastion-public-ip"
secops-myNVA-public-ip-name = "customer-mynva-public-ip"
secops-appgw-public-ip-name = "customer-appgw-public-ip"
# DNS zones
secops-dns-zone-name       = "cxp.azure.strangebee.com"
secops-private-zone-name  = "strangebee.cloud"

## Instances
# Bastion
secops-bastion-computer-name = "customer-bastion"
secops-bastion-vm-size = "Standard_B2s"
secops-bastion-admin-user = "ubuntu"
secops-bastion-public-key-path = "~/.ssh/id_rsa.pub"
# myNVA
secops-myNVA-computer-name = "customer-myNVA"
secops-myNVA-vm-size = "Standard_DS2_v2"
secops-myNVA-admin-user = "ubuntu"
secops-myNVA-public-key-path = "~/.ssh/id_rsa.pub"
# Common: managed OS Disk type - possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS
secops-os-disk-type   = "Standard_LRS"

# IP filtering whitelist (Jerome, Alex, Bauhaus)
secops-users = ["90.62.231.158/32", "176.173.74.21/32","212.129.53.219/32"]

# KeyVault name
secops-key-vault-name = "customer-xp-key-vault"
