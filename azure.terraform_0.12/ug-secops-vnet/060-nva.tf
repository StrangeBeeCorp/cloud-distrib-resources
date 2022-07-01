
# Create Static IP for myNVA instance
resource "azurerm_public_ip" "secops-myNVA-public-ip" {
  name                = var.secops-myNVA-public-ip-name
  resource_group_name = var.secops-resource-group-name
  location            = var.secops-location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags = {
    Name= "secops-myNVA-public-ip"
  }
}

# Create WAN Network Interface Card for myNVA instance
resource "azurerm_network_interface" "secops-nic-wan-myNVA" {
  name                = "secops-nic-wan-myNVA"
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name

  ip_configuration {
    name                          = "secops-myNVA-ip-wan-config"
    subnet_id                     = azurerm_subnet.secops-public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.secops-myNVA-public-ip.id
  }
  
  # Enable IP forwarding and accelerated networking on the wan network interface card
  enable_ip_forwarding = true 
  enable_accelerated_networking = true
  tags = {
    Name= "secops-nic-wan-myNVA"
  }
}

# Create LAN Network Interface Card for myNVA instance
resource "azurerm_network_interface" "secops-nic-lan-myNVA" {
  name                = "secops-nic-lan-myNVA"
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name

  ip_configuration {
    name                          = "secops-myNVA-ip-lan-config"
    subnet_id                     = azurerm_subnet.secops-backend-private-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  # Enable accelerated networking on the lan network interface card
  enable_accelerated_networking = true
  tags = {
    Name= "secops-nic-lan-myNVA"
  }
}

# Create myNVA VM instance
resource "azurerm_virtual_machine" "secops-myNVA-instance" {
  name                = var.secops-myNVA-computer-name
  location            = var.secops-location 
  resource_group_name = var.secops-resource-group-name
  vm_size                = var.secops-myNVA-vm-size
  network_interface_ids = [azurerm_network_interface.secops-nic-wan-myNVA.id,azurerm_network_interface.secops-nic-lan-myNVA.id]
  
  # Specify the wan-nic as the primary network interface card
  primary_network_interface_id = azurerm_network_interface.secops-nic-wan-myNVA.id
  
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  storage_os_disk {
    name = "secops-os-disk-myNVA"
    caching = "ReadWrite"
    create_option = "FromImage"
    os_type = "Linux"
    managed_disk_type = var.secops-os-disk-type
  }
  os_profile {
    computer_name  = var.secops-myNVA-computer-name
    admin_username = var.secops-myNVA-admin-user  
    custom_data = file("files/nva-nat-cloud-config.yaml")
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.secops-myNVA-public-key-path)
      path = "/home/${var.secops-myNVA-admin-user}/.ssh/authorized_keys"
    }
  }

  depends_on = [
    azurerm_network_security_group.secops-public-nsg,
    azurerm_network_interface.secops-nic-lan-myNVA,
    azurerm_network_interface.secops-nic-wan-myNVA,
    azurerm_network_interface_security_group_association.secops-nic-lan-myNVA-secops-nic-lan-myNVA-nsg-association
  ]
}
