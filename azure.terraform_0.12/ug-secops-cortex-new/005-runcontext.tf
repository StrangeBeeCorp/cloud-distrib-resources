# Here we look for existing resources
data "azurerm_subscription" "current-subscription" {
}

data "azurerm_virtual_network" "secops-vnet" {
  name                = var.secops-virtual-network-name
  resource_group_name = var.secops-resource-group-name
}
# secops-vnet-id = "${data.azurerm_virtual_network.secops-vnet.id}"

data "azurerm_subnet" "secops-backend-private-subnet" {
  name                 = var.secops-backend-private-subnet-name
  resource_group_name  = var.secops-resource-group-name
  virtual_network_name = data.azurerm_virtual_network.secops-vnet.name
}
# secops-backend-private-subnet-id = "${data.azurerm_subnet.secops-backend-private-subnet.id}"

data "azurerm_private_dns_zone" "secops-private-zone" {
  name                = var.secops-private-zone-name
  resource_group_name = var.secops-resource-group-name
}
# secops-private-zone-id = "${data.azurerm_private_dns_zone.secops-private-zone.id}"

data "azurerm_network_security_group" "secops-nic-lan-myNVA-nsg" {
  name                = var.secops-nic-lan-myNVA-nsg-name
  resource_group_name = var.secops-resource-group-name
}
# secops-nic-lan-myNVA-nsg-id = "${azurerm_network_security_group.secops-nic-lan-myNVA-nsg.id}"

data "azurerm_network_security_group" "secops-public-nsg" {
  name                = var.secops-public-nsg-name
  resource_group_name = var.secops-resource-group-name
}
# secops-public-nsg-id = "${azurerm_network_security_group.secops-public-nsg.id}"

data "azurerm_network_interface" "secops-nic-bastion" {
  name                = var.secops-nic-bastion-name
  resource_group_name = var.secops-resource-group-name
}
# secops-nic-bastion-id = "${azurerm_network_interface.secops-nic-bastion.id}"
