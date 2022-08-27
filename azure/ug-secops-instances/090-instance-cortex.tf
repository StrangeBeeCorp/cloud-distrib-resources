# Create Network Interface Card for cortex instance
resource "azurerm_network_interface" "secops-nic-cortex" {
  name                = "secops-nic-cortex"
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name

  ip_configuration {
    name                          = "secops-cortex-ip-config"
    subnet_id                     = data.azurerm_subnet.secops-backend-private-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Name= "secops-nic-cortex"
  }
}

# Add cortex private address to cortex backend address pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "secops-cortex-nic-cortex-backend-pool-association" {
  network_interface_id    = azurerm_network_interface.secops-nic-cortex.id
  ip_configuration_name   = "secops-cortex-ip-config"
  backend_address_pool_id = "${data.azurerm_subscription.current-subscription.id}/resourceGroups/${var.secops-resource-group-name}/providers/Microsoft.Network/applicationGateways/${var.secops-appgw-name}/backendAddressPools/${var.secops-cortex-backend-pool-name}"
}

# Create Cortex DNS record, Type "A",  in the private zone (cortex.secops.cloud)
resource "azurerm_private_dns_a_record" "secops-private-dns-cortex-record" {
  name                = var.secops-cortex-computer-name
  zone_name           = data.azurerm_private_dns_zone.secops-private-zone.name
  resource_group_name = var.secops-resource-group-name
  ttl                 = 300
  records             = [azurerm_network_interface.secops-nic-cortex.private_ip_address]
  tags = {
    Name= "secops-private-dns-cortex-record"
  }

}

# Create cortex VM instance
resource "azurerm_virtual_machine" "secops-cortex-instance" {
  name                = var.secops-cortex-computer-name
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name
  vm_size                = var.secops-cortex-vm-size
  network_interface_ids = [azurerm_network_interface.secops-nic-cortex.id]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "strangebee1595948424730"
    offer     = var.secops-thehive-product
    sku       = "thehive5"
    version   = var.secops-thehive-version
  }
  plan {
    name = "thehive5"
    publisher = "strangebee1595948424730"
    product = var.secops-thehive-product 
  }

  storage_os_disk {
    name = var.secops-cortex-os-disk-name 
    caching = "ReadWrite"
    create_option = "FromImage"
    os_type = "Linux"
    managed_disk_type = var.secops-os-disk-type
  }

  os_profile {
    computer_name  = var.secops-cortex-computer-name
    admin_username = var.secops-admin-user  
    custom_data = templatefile("${path.module}/files/cloud-config.tpl", {
      installthehive = "0",
      installcortex = "1",
      thehivebaseurl = "${var.secops-th-baseurl}",
      thehivecontext = "/thehive",
      cortexcontext = "/cortex",
      imagethehive = "${var.secops-image-th-version}",
      imagecortex = "${var.secops-image-cortex-version}",
      imagecassandra = "${var.secops-image-cassandra-version}",
      imageelasticsearch = "${var.secops-image-elasticsearch-version}",
      imagenginx = "${var.secops-image-nginx-version}",
      hostname = "${var.secops-cortex-computer-name}"
    })
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.secops-public-key-path)
      path = "/home/${var.secops-admin-user}/.ssh/authorized_keys"
    }
  }

  storage_data_disk {
    name = var.secops-cortex-data-disk-name
    caching = "ReadWrite"
    create_option = "Attach"
    managed_disk_id = data.azurerm_managed_disk.cortex-data-disk.id
    disk_size_gb  = data.azurerm_managed_disk.cortex-data-disk.disk_size_gb    
    lun = 0
  }

  storage_data_disk {
    name = var.secops-cortex-docker-disk-name
    caching = "ReadWrite"
    create_option = "Attach"
    managed_disk_id = data.azurerm_managed_disk.cortex-docker-disk.id
    disk_size_gb  = data.azurerm_managed_disk.cortex-docker-disk.disk_size_gb    
    lun = 1
  }
  
  depends_on = [
    azurerm_network_interface_security_group_association.secops-nic-cortex-secops-cortex-nsg-association,
    azurerm_network_security_group.secops-cortex-nsg,
    azurerm_network_interface_application_gateway_backend_address_pool_association.secops-cortex-nic-cortex-backend-pool-association,
    azurerm_network_interface.secops-nic-cortex
  ]
}
