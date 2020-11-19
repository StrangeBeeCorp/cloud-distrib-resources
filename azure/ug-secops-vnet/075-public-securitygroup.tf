# Create network security group for the public subnet
resource "azurerm_network_security_group" "secops-public-nsg" {
  name                 = "secops-public-nsg"
  location             = var.secops-location
  resource_group_name  = var.secops-resource-group-name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name= "secops-public-nsg"
  }
}

### For all rules, Microsoft recommends that the value for source port ranges is * (Any). Port filtering is mainly used with destination port.

## Public NSG Inbound rules

# Create bastion ssh rule for ssh users access (secops users) - secops-public-nsg
resource "azurerm_network_security_rule" "secops-users-bastion-ssh-rule" {
  name                        = "secops-users-bastion-ssh-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefixes     = var.secops-users
  destination_address_prefix  = azurerm_network_interface.secops-nic-bastion.private_ip_address
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-public-nsg.name
}

# Create DenyVnetInBound rule - secops-public-nsg
resource "azurerm_network_security_rule" "DenyVnetInBound-secops-public-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-public-nsg.name  
}

# Create  DenyAzureLoadBalancerInBound rule - secops-public-nsg
resource "azurerm_network_security_rule" "DenyAzureLoadBalancerInBound-secops-public-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-public-nsg.name  
}

## Public NSG Outbound rules

# Create myNVA internet outbound rule - secops-public-nsg
resource "azurerm_network_security_rule" "secops-myNVA-internet-outbound-rule" {
  name                        = "secops-myNVA-internet-outbound-rule"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_network_interface.secops-nic-wan-myNVA.private_ip_address
  destination_address_prefix  = "Internet"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-public-nsg.name
}

# Create DenyVnetOutBound rule - secops-public-nsg
resource "azurerm_network_security_rule" "DenyVnetOutBound-secops-public-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-public-nsg.name  
}

# Create DenyInternetOutBound rule - secops-public-nsg
resource "azurerm_network_security_rule" "DenyInternetOutBound-secops-public-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-public-nsg.name 
  
  depends_on = [
    azurerm_network_security_rule.secops-myNVA-internet-outbound-rule
  ]
}

# Link the public network security group to the public subnet
resource "azurerm_subnet_network_security_group_association" "secops-public-subnet-secops-public-nsg-association" {
  subnet_id                 = azurerm_subnet.secops-public-subnet.id
  network_security_group_id = azurerm_network_security_group.secops-public-nsg.id
}



