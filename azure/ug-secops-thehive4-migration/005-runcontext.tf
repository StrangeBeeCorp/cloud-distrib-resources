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


data "azurerm_network_interface" "secops-nic-cortex" {
  count = var.enable_cortex_connection ? 1 : 0
  name                = var.secops-nic-cortex-name
  resource_group_name = var.secops-resource-group-name
}
# secops-nic-cortex-id = "${azurerm_network_interface.secops-nic-cortex.id}"

data "azurerm_network_security_group" "secops-cortex-nsg" {
  count = var.enable_cortex_connection ? 1 : 0
  name                = var.secops-cortex-nsg-name
  resource_group_name = var.secops-resource-group-name
}
# secops-cortex-nsg-id = "${azurerm_network_security_group.secops-cortex-nsg.id}"

data "azurerm_managed_disk" "thehive-data-disk" {
  name                = var.secops-data-disk-name
  resource_group_name = var.secops-resource-group-name
}
# thehive-data-disk-id = "${azurerm_managed_disk.thehive-data-disk.id}"

data "azurerm_managed_disk" "thehive-storage-disk" {
  name                = var.secops-storage-disk-name
  resource_group_name = var.secops-resource-group-name
}
# thehive-storage-disk-id = "${azurerm_managed_disk.thehive-storage-disk.id}"

data "azurerm_managed_disk" "thehive-index-disk" {
  name                = var.secops-index-disk-name
  resource_group_name = var.secops-resource-group-name
}
# thehive-index-disk-id = "${azurerm_managed_disk.thehive-index-disk.id}"