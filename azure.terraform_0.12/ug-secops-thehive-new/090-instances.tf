# Create Network Interface Card for thehive instance
resource "azurerm_network_interface" "secops-nic-thehive" {
  name                = "secops-nic-thehive"
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name

  ip_configuration {
    name                          = "secops-thehive-ip-config"
    subnet_id                     = data.azurerm_subnet.secops-backend-private-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Name= "secops-nic-thehive"
  }
}

# Add thehive private address to thehive backend address pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "secops-thehive-nic-thehive-backend-pool-association" {
  network_interface_id    = azurerm_network_interface.secops-nic-thehive.id
  ip_configuration_name   = "secops-thehive-ip-config"
  backend_address_pool_id = "${data.azurerm_subscription.current-subscription.id}/resourceGroups/${var.secops-resource-group-name}/providers/Microsoft.Network/applicationGateways/${var.secops-appgw-name}/backendAddressPools/${var.secops-thehive-backend-pool-name}"
}

# Create TheHive DNS record, Type "A", in the private zone
resource "azurerm_private_dns_a_record" "secops-private-dns-thehive-record" {
  name                = "thehive"
  zone_name           = data.azurerm_private_dns_zone.secops-private-zone.name
  resource_group_name = var.secops-resource-group-name
  ttl                 = 300
  records             = [azurerm_network_interface.secops-nic-thehive.private_ip_address]
  tags = {
    Name= "secops-private-dns-thehive-record"
  }

}

# Create thehive VM instance
resource "azurerm_virtual_machine" "secops-thehive-instance" {
  name                = var.secops-computer-name
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name
  vm_size                = var.secops-vm-size
  network_interface_ids = [azurerm_network_interface.secops-nic-thehive.id]
  delete_os_disk_on_termination = true
  storage_os_disk {
    name = "secops-thehive3-os-disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    os_type = "Linux"
    managed_disk_type = var.secops-os-disk-type
  }
  os_profile {
    computer_name  = var.secops-computer-name
    admin_username = var.secops-admin-user  
    custom_data = file("files/th-cloud-config-new.yaml")
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.secops-public-key-path)
      path = "/home/${var.secops-admin-user}/.ssh/authorized_keys"
    }
  }
  storage_data_disk {
    name = var.secops-data-disk-name
    caching = "ReadWrite"
    create_option = "Empty"
    disk_size_gb = var.secops-data-disk-size
    lun = 0
    managed_disk_type = var.secops-data-disk-type
    }

  storage_image_reference {
    publisher = "strangebee1595948424730"
    offer     = "thehive-3"
    sku       = "thehive3"
    version   = "latest"
  }
  plan {
    name = "thehive3"
    publisher = "strangebee1595948424730"
    product = "thehive-3" 
  }
  
  depends_on = [
    azurerm_network_interface_security_group_association.secops-nic-thehive-secops-thehive-nsg-association,
    azurerm_network_security_group.secops-thehive-nsg,
    azurerm_network_interface_application_gateway_backend_address_pool_association.secops-thehive-nic-thehive-backend-pool-association,
    azurerm_network_interface.secops-nic-thehive
  ]
}
