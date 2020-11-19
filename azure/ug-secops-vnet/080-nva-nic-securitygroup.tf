# Create network security group for the LAN Network Interface Card (myNVA)
resource "azurerm_network_security_group" "secops-nic-lan-myNVA-nsg" {
  name                 = "secops-nic-lan-myNVA-nsg"
  location             = var.secops-location
  resource_group_name  = var.secops-resource-group-name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name= "secops-nic-lan-myNVA-nsg"
  }
}

### For all rules, Microsoft recommends that the value for source port ranges is * (Any). Port filtering is mainly used with destination port.

## LAN myNVA NSG Inbound rules

# Create DenyVnetInBound rule - secops-nic-lan-myNVA-nsg
resource "azurerm_network_security_rule" "DenyVnetInBound-secops-nic-lan-myNVA-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-nic-lan-myNVA-nsg.name  
}

# Create  DenyAzureLoadBalancerInBound rule - secops-nic-lan-myNVA-nsg
resource "azurerm_network_security_rule" "DenyAzureLoadBalancerInBound-secops-nic-lan-myNVA-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-nic-lan-myNVA-nsg.name  
}

## LAN myNVA NSG Outbound rules

# Create DenyInternetOutBound rule - secops-nic-lan-myNVA-nsg
resource "azurerm_network_security_rule" "DenyInternetOutBound-secops-nic-lan-myNVA-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-nic-lan-myNVA-nsg.name 
}

# Create DenyVnetOutBound rule - secops-nic-lan-myNVA-nsg
resource "azurerm_network_security_rule" "DenyVnetOutBound-secops-nic-lan-myNVA-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-nic-lan-myNVA-nsg.name  
}

# Link the LAN myNVA network security group to the nic-lan-myNVA
resource "azurerm_network_interface_security_group_association" "secops-nic-lan-myNVA-secops-nic-lan-myNVA-nsg-association" {
  network_interface_id      = azurerm_network_interface.secops-nic-lan-myNVA.id
  network_security_group_id = azurerm_network_security_group.secops-nic-lan-myNVA-nsg.id
}



