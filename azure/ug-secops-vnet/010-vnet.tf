# NOTE : The target subscription, resource group, key vault and public DNS zone must already exist

# Create new SecOps Virtual Network
resource "azurerm_virtual_network" "secops-vnet" {
  name                = var.secops-virtual-network-name
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name
  address_space       = [var.secops-vnet]
  tags = {
    Name= "secops-vnet"
  }
}

# Create private DNS zone
resource "azurerm_private_dns_zone" "secops-private-zone" {
  name                = var.secops-private-zone-name
  resource_group_name = var.secops-resource-group-name
  tags = {
    Name= "secops-private-zone"
  }
}

# Link private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "secops-link-private-dns-vnet" {
  name                  = "secops-link-private-dns-vnet"
  resource_group_name   = var.secops-resource-group-name
  private_dns_zone_name = azurerm_private_dns_zone.secops-private-zone.name
  virtual_network_id    = azurerm_virtual_network.secops-vnet.id
  tags = {
    Name= "secops-link-private-dns-vnet"
  }
}

# Create the appgw subnet 
resource "azurerm_subnet" "secops-appgw-frontend-public-subnet" {
  name                 = var.secops-appgw-frontend-public-subnet-name
  resource_group_name  = var.secops-resource-group-name
  virtual_network_name = azurerm_virtual_network.secops-vnet.name
  address_prefixes     = [var.secops-appgw-frontend-public-subnet]
}

# Create the private subnet 
resource "azurerm_subnet" "secops-backend-private-subnet" {
  name                 = var.secops-backend-private-subnet-name
  resource_group_name  = var.secops-resource-group-name
  virtual_network_name = azurerm_virtual_network.secops-vnet.name
  address_prefixes     = [var.secops-backend-private-subnet]
}

# Create the public subnet 
resource "azurerm_subnet" "secops-public-subnet" {
  name                 = var.secops-public-subnet-name
  resource_group_name  = var.secops-resource-group-name
  virtual_network_name = azurerm_virtual_network.secops-vnet.name
  address_prefixes     = [var.secops-public-subnet]
}