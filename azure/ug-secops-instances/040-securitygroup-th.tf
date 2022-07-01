# Create network security group for thehive instance
resource "azurerm_network_security_group" "secops-thehive-nsg" {
  name                = "secops-thehive-nsg"
  location            = var.secops-location
  resource_group_name = var.secops-resource-group-name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name= "secops-thehive-nsg"
  }

}

## TheHive NSG Inbound rules

# Create thehive inbound rule for appgw - secops-thehive-nsg
resource "azurerm_network_security_rule" "secops-thehive-inbound-appgw-rule" {
  name                        = "secops-thehive-inbound-appgw-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443", "9000"]
  source_address_prefix       = var.secops-appgw-frontend-public-subnet
  destination_address_prefix  = azurerm_network_interface.secops-nic-thehive.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name
}

# Create bastion to thehive ssh inbound rule - secops-thehive-nsg
resource "azurerm_network_security_rule" "secops-bastion-to-thehive-inbound-rule" {
  name                        = "secops-bastion-to-thehive-inbound-rule"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = data.azurerm_network_interface.secops-nic-bastion.private_ip_address
  destination_address_prefix  = azurerm_network_interface.secops-nic-thehive.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name
}


# Create DenyVnetInBound rule - secops-thehive-nsg
resource "azurerm_network_security_rule" "DenyVnetInBound-secops-thehive-nsg" {
  name                        = "DenyVnetInBound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name  
}

# Create  DenyAzureLoadBalancerInBound rule - secops-thehive-nsg
resource "azurerm_network_security_rule" "DenyAzureLoadBalancerInBound-secops-thehive-nsg" {
  name                        = "DenyAzureLoadBalancerInBound"
  priority                    = 4001
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name  
}


## TheHive NSG OutBound rules

# Create thehive internet outbound rule - secops-thehive-nsg
resource "azurerm_network_security_rule" "secops-thehive-internet-outbound-rule" {
  name                        = "secops-thehive-internet-outbound-rule"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_network_interface.secops-nic-thehive.private_ip_address
  destination_address_prefix  ="Internet"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name
}

# Create DenyInternetOutBound rule - secops-thehive-nsg
resource "azurerm_network_security_rule" "DenyInternetOutBound-secops-thehive-nsg" {
  name                        = "DenyInternetOutBound"
  priority                    = 4001
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name 
}

# Create DenyVnetOutBound rule - secops-thehive-nsg
resource "azurerm_network_security_rule" "DenyVnetOutBound-secops-thehive-nsg" {
  name                        = "DenyVnetOutBound"
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name  
}

## Public NSG OutBound rules

# Create bastion to thehive ssh outbound rule - secops-public-nsg
resource "azurerm_network_security_rule" "secops-bastion-to-thehive-outbound-rule" {
  name                        = "secops-bastion-to-thehive-outbound-rule"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = data.azurerm_network_interface.secops-nic-bastion.private_ip_address
  destination_address_prefix  = azurerm_network_interface.secops-nic-thehive.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = data.azurerm_network_security_group.secops-public-nsg.name
}

## LAN myNVA NSG InBound rules

# Create thehive to lan-nic-myNVA Inbound rule - secops-nic-lan-myNVA-nsg
resource "azurerm_network_security_rule" "secops-thehive-to-lan-nic-myNVA-inbound-rule" {
  name                        = "secops-thehive-to-lan-nic-myNVA-inbound-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_network_interface.secops-nic-thehive.private_ip_address
  destination_address_prefix  = "0.0.0.0/0"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = data.azurerm_network_security_group.secops-nic-lan-myNVA-nsg.name
}

# Create thehive-to-cortex outbound rule - secops-thehive-nsg
resource "azurerm_network_security_rule" "secops-thehive-to-cortex-outbound-rule" {
  name                        = "secops-thehive-to-cortex-outbound-rule"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443", "9001"]
  source_address_prefix       = azurerm_network_interface.secops-nic-thehive.private_ip_address
  destination_address_prefix  = azurerm_network_interface.secops-nic-cortex.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-thehive-nsg.name
}

# Create thehive-to-cortex inbound rule - secops-cortex-nsg
resource "azurerm_network_security_rule" "secops-thehive-to-cortex-inbound-rule" {
  name                        = "secops-thehive-to-cortex-inbound-rule"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443", "9001"]
  source_address_prefix       = azurerm_network_interface.secops-nic-thehive.private_ip_address
  destination_address_prefix  = azurerm_network_interface.secops-nic-cortex.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name
}

# Link thehive network security group to the nic-thehive
resource "azurerm_network_interface_security_group_association" "secops-nic-thehive-secops-thehive-nsg-association" {
  network_interface_id      = azurerm_network_interface.secops-nic-thehive.id
  network_security_group_id = azurerm_network_security_group.secops-thehive-nsg.id
}
