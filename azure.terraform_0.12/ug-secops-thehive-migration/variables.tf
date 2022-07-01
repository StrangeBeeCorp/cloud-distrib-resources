
variable "secops-resource-group-name" {
  type = string
  description = "Name of build resource group"
}
variable "secops-location" {
  type = string
  description = "Name of build location"
}

variable "secops-virtual-network-name" {
  type = string
  description = "secops Virtual Network name"
}

variable "secops-backend-private-subnet-name" {
  type = string
  description = "Backend private subnet name"
}

variable "secops-computer-name" {
  type = string
  description = "Computer name (hostname)"
}
variable "secops-admin-user" {
  type = string
  description = "Admin user"
}
variable "secops-public-key-path" {
  type = string
  description = "Path for public key"
}

variable "secops-private-zone-name" {
  type = string
  description = "DNS private zone in Azure DNS"
}

variable "secops-appgw-name" {
  type = string
  description = "Application Gateway name"
}

variable "secops-thehive-backend-pool-name" {
  type = string
  description = "Application Gateway thehive backend pool name"
}

variable "secops-data-disk-type" {
  type = string
  description = "Data disk type"
}

variable "secops-vm-size" {
  type = string
  description = "TheHive VM size"
}

variable "secops-os-disk-type" {
  type = string
  description = "OS disk type"
}

variable "secops-data-disk-name" {
  type = string
  description = "Data disk name"
}

variable "secops-nic-lan-myNVA-nsg-name" {
  type = string
  description = "NIC LAN myNVA network security group name"
}

variable "secops-public-nsg-name" {
  type = string
  description = "Public network security group name"
}

variable "secops-appgw-frontend-public-subnet" {
  type = string
  description = "Application Gateway subnet CIDR"
}

variable "secops-nic-bastion-name" {
  type = string
  description = "Bastion NIC name"
}

variable "secops-nic-cortex-name" {
  type = string
  description = "Cortex NIC name"
}

variable "enable_cortex_connection" {
  type        = bool
  description = "If set to true, enable cortex connection"
}

variable "secops-cortex-nsg-name" {
  type = string
  description = "Cortex network security group name"
}