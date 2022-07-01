
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

variable "secops-cortex-backend-pool-name" {
  type = string
  description = "Application Gateway cortex backend pool name"
}

variable "secops-data-disk-name" {
  type = string
  description = "Data ES disk name"
}

variable "secops-data-disk-type" {
  type = string
  description = "Data disk type"
}

variable "secops-data-disk-size" {
  type = string
  description = "Size in GB of TheHive data disk (Elasticsearch)"
}

variable "secops-docker-disk-name" {
  type = string
  description = "Data Docker disk name"
}

variable "secops-docker-disk-size" {
  type = string
  description = "Size in GB of TheHive data disk (Docker)"
}

variable "secops-vm-size" {
  type = string
  description = "TheHive VM size"
}

variable "secops-os-disk-type" {
  type = string
  description = "OS disk type"
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

