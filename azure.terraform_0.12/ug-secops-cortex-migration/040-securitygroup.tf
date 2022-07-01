  # Create network security group for cortex instance
resource "azurerm_network_security_group" "secops-cortex-nsg" {
  name                = "secops-cortex-nsg"
  location            = var.secops-location
  resource_group_name = var.secops-resource-group-name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name= "secops-cortex-nsg"
  }

}

## Cortex NSG Inbound rules

# Create cortex inbound rule for appgw - secops-cortex-nsg
resource "azurerm_network_security_rule" "secops-cortex-inbound-appgw-rule" {
  name                        = "secops-cortex-inbound-appgw-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 9001
  source_address_prefix       = var.secops-appgw-frontend-public-subnet
  destination_address_prefix  = azurerm_network_interface.secops-nic-cortex.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name
}

# Create bastion to cortex ssh inbound rule - secops-cortex-nsg
resource "azurerm_network_security_rule" "secops-bastion-to-cortex-inbound-rule" {
  name                        = "secops-bastion-to-cortex-inbound-rule"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = data.azurerm_network_interface.secops-nic-bastion.private_ip_address
  destination_address_prefix  = azurerm_network_interface.secops-nic-cortex.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name
}


# Create DenyVnetInBound rule - secops-cortex-nsg
resource "azurerm_network_security_rule" "DenyVnetInBound-secops-cortex-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name  
}

# Create  DenyAzureLoadBalancerInBound rule - secops-cortex-nsg
resource "azurerm_network_security_rule" "DenyAzureLoadBalancerInBound-secops-cortex-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name  
}


## Cortex NSG OutBound rules

# Create cortex internet outbound rule - secops-cortex-nsg
resource "azurerm_network_security_rule" "secops-cortex-internet-outbound-rule" {
  name                        = "secops-cortex-internet-outbound-rule"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_network_interface.secops-nic-cortex.private_ip_address
  destination_address_prefix  ="Internet"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name
}

# Create DenyInternetOutBound rule - secops-cortex-nsg
resource "azurerm_network_security_rule" "DenyInternetOutBound-secops-cortex-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name 
}

# Create DenyVnetOutBound rule - secops-cortex-nsg
resource "azurerm_network_security_rule" "DenyVnetOutBound-secops-cortex-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-cortex-nsg.name  
}

## Public NSG OutBound rules

# Create bastion to cortex ssh outbound rule - secops-public-nsg
resource "azurerm_network_security_rule" "secops-bastion-to-cortex-outbound-rule" {
  name                        = "secops-bastion-to-cortex-outbound-rule"
  priority                    = 300
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = data.azurerm_network_interface.secops-nic-bastion.private_ip_address
  destination_address_prefix  = azurerm_network_interface.secops-nic-cortex.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = data.azurerm_network_security_group.secops-public-nsg.name
}

## LAN myNVA NSG InBound rules

# Create cortex to lan-nic-myNVA Inbound rule - secops-nic-lan-myNVA-nsg
resource "azurerm_network_security_rule" "secops-cortex-to-lan-nic-myNVA-inbound-rule" {
  name                        = "secops-cortex-to-lan-nic-myNVA-inbound-rule"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_network_interface.secops-nic-cortex.private_ip_address
  destination_address_prefix  = "0.0.0.0/0"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = data.azurerm_network_security_group.secops-nic-lan-myNVA-nsg.name
}

# Link cortex network security group to the nic-cortex
resource "azurerm_network_interface_security_group_association" "secops-nic-cortex-secops-cortex-nsg-association" {
  network_interface_id      = azurerm_network_interface.secops-nic-cortex.id
  network_security_group_id = azurerm_network_security_group.secops-cortex-nsg.id
}
