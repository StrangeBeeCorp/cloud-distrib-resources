# Create network security group for the appgw subnet
resource "azurerm_network_security_group" "secops-appgw-nsg" {
  name                 = "secops-appgw-nsg"
  location             = var.secops-location
  resource_group_name  = var.secops-resource-group-name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name= "secops-appgw-nsg"
  }
}

### For all rules, Microsoft recommends that the value for source port ranges is * (Any). Port filtering is mainly used with destination port.

## AppGW NSG Inbound rules

# Create access users rule - secops-appgw-nsg
resource "azurerm_network_security_rule" "secops-appgw-access-users-rule" {
    name                        = "secops-appgw-access-users-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 443
  source_address_prefixes     = var.secops-users
  destination_address_prefix  = var.secops-appgw-frontend-public-subnet
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-appgw-nsg.name
}

# Create backend health communication rule - secops-appgw-nsg
resource "azurerm_network_security_rule" "secops-appgw-backend-health-communication-rule" {
  name                        = "secops-appgw-backend-health-communication-rule"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-appgw-nsg.name  
}

# Create backend communication rule - secops-appgw-nsg
resource "azurerm_network_security_rule" "secops-appgw-backend-communication-rule" {
  name                        = "secops-appgw-backend-communication-rule"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.secops-resource-group-name
  network_security_group_name = azurerm_network_security_group.secops-appgw-nsg.name  
}

# Create DenyVnetInBound rule - secops-appgw-nsg
resource "azurerm_network_security_rule" "DenyVnetInBound-secops-appgw-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-appgw-nsg.name  
}

# Create AppGw DenyAzureLoadBalancerInBound rule - secops-appgw-nsg
resource "azurerm_network_security_rule" "DenyAzureLoadBalancerInBound-secops-appgw-nsg" {
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
  network_security_group_name = azurerm_network_security_group.secops-appgw-nsg.name 

  depends_on = [
    azurerm_network_security_rule.secops-appgw-backend-communication-rule
  ]
}

# Link the appgw network security group to the appgw subnet
resource "azurerm_subnet_network_security_group_association" "secops-appgw-frontend-public-subnet-secops-appgw-nsg-association" {
  subnet_id                 = azurerm_subnet.secops-appgw-frontend-public-subnet.id
  network_security_group_id = azurerm_network_security_group.secops-appgw-nsg.id

  depends_on = [
    azurerm_network_security_rule.secops-appgw-backend-health-communication-rule
  ]
}
