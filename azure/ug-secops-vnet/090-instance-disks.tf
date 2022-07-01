resource "azurerm_managed_disk" "th-data-disk" {
  name                 = var.secops-th-data-disk-name
  resource_group_name  = var.secops-resource-group-name
  location             = var.secops-location
  storage_account_type = var.secops-th-data-disk-type
  create_option        = "Empty"
  disk_size_gb         = var.secops-th-data-disk-size

  tags = {
    name        = "${var.secops-th-data-disk-name}"
    environment = "secops"
  }
}

resource "azurerm_managed_disk" "th-docker-disk" {
  name                 = var.secops-th-docker-disk-name
  resource_group_name  = var.secops-resource-group-name
  location             = var.secops-location
  storage_account_type = var.secops-th-docker-disk-type
  create_option        = "Empty"
  disk_size_gb         = var.secops-th-docker-disk-size

  tags = {
    name        = "${var.secops-th-docker-disk-name}"
    environment = "secops"
  }
}

resource "azurerm_managed_disk" "cortex-data-disk" {
  name                 = var.secops-cortex-data-disk-name
  resource_group_name  = var.secops-resource-group-name
  location             = var.secops-location
  storage_account_type = var.secops-cortex-data-disk-type
  create_option        = "Empty"
  disk_size_gb         = var.secops-cortex-data-disk-size

  tags = {
    name        = "${var.secops-cortex-data-disk-name}"
    environment = "secops"
  }
}

resource "azurerm_managed_disk" "cortex-docker-disk" {
  name                 = var.secops-cortex-docker-disk-name
  resource_group_name  = var.secops-resource-group-name
  location             = var.secops-location
  storage_account_type = var.secops-cortex-docker-disk-type
  create_option        = "Empty"
  disk_size_gb         = var.secops-cortex-docker-disk-size

  tags = {
    name        = "${var.secops-cortex-docker-disk-name}"
    environment = "secops"
  }
}
