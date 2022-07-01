# Create route table 
resource "azurerm_route_table" "secops-route-table" {
  name                          = "secops-route-table"
  resource_group_name           = var.secops-resource-group-name
  location                      = var.secops-location
  disable_bgp_route_propagation = false

  route {
    name           = "ToMyNVARoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.secops-nic-lan-myNVA.private_ip_address
  }

  tags = {
   NAME= "secops-route-table"
  }

  depends_on = [
   azurerm_subnet.secops-backend-private-subnet,
   azurerm_virtual_machine.secops-myNVA-instance
  ]
}

resource "azurerm_subnet_route_table_association" "secops-backend-private-subnet-secops-route-table-association" {
  subnet_id      = azurerm_subnet.secops-backend-private-subnet.id
  route_table_id = azurerm_route_table.secops-route-table.id
}