# Create Static IP for bastion host instance
resource "azurerm_public_ip" "secops-bastion-public-ip" {
  name                = var.secops-bastion-public-ip-name
  resource_group_name = var.secops-resource-group-name
  location            = var.secops-location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags = {
    Name= "secops-bastion-public-ip"
  }
}

# Create Network Interface Card for bastion host instance
resource "azurerm_network_interface" "secops-nic-bastion" {
  name                = "secops-nic-bastion"
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name

  ip_configuration {
    name                          = "secops-bastion-ip-config"
    subnet_id                     = azurerm_subnet.secops-public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.secops-bastion-public-ip.id
  }

  tags = {
    Name= "secops-nic-bastion"
  }
}

# Create bastion host VM instance
resource "azurerm_virtual_machine" "secops-bastion-instance" {
  name                = var.secops-bastion-computer-name
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name
  vm_size                = var.secops-bastion-vm-size
  network_interface_ids = [azurerm_network_interface.secops-nic-bastion.id]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  storage_os_disk {
    name = "secops-os-disk-bastion"
    caching = "ReadWrite"
    create_option = "FromImage"
    os_type = "Linux"
    managed_disk_type = var.secops-os-disk-type
  }
  os_profile {
    computer_name  = var.secops-bastion-computer-name
    admin_username = var.secops-bastion-admin-user  
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.secops-bastion-public-key-path)
      path = "/home/${var.secops-bastion-admin-user}/.ssh/authorized_keys"
    }
  }

  depends_on = [
    azurerm_network_security_group.secops-public-nsg,
    azurerm_network_interface.secops-nic-bastion
  ]
}
