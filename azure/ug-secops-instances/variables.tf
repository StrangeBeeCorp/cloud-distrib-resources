
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

variable "secops-th-computer-name" {
  type = string
  description = "TheHive Computer name (hostname)"
}

variable "secops-cortex-computer-name" {
  type = string
  description = "Cortex Computer name (hostname)"
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

variable "secops-cortex-backend-pool-name" {
  type = string
  description = "Application Gateway cortex backend pool name"
}

variable "secops-th-vm-size" {
  type = string
  description = "TheHive VM size"
}

variable "secops-cortex-vm-size" {
  type = string
  description = "Cortex VM size"
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

variable "secops-nic-cortex-name" {
  type = string
  description = "Cortex NIC name"
}

variable "secops-cortex-nsg-name" {
  type = string
  description = "Cortex network security group name"
}

variable "secops-th-os-disk-name" {
  type = string
  description = "secops-th-os-disk-name"  
}

variable "secops-th-data-disk-name" {
  type = string
  description = "secops-th-data-disk-name"  
}

variable "secops-th-docker-disk-name" {
  type = string
  description = "secops-th-docker-disk-name"
}

variable "secops-cortex-os-disk-name" {
  type = string
  description = "secops-cortex-os-disk-name"
}

variable "secops-cortex-data-disk-name" {
  type = string
  description = "secops-cortex-data-disk-name"
}

variable "secops-cortex-docker-disk-name" {
  type = string
  description = "secops-cortex-docker-disk-name"
}

variable "secops-thehive-product" {
  type = string
  description = "secops-thehive-product"
  default = "thehive-5"
}

variable "secops-thehive-version" {
  type = string
  description = "secops-thehive-version"
  default = "latest"
}

variable "secops-th-baseurl" {
  type = string
  description = "secops-th-baseurl"
}

variable "secops-image-th-version" {
  type = string
  description = "secops-image-th-version"
}

variable "secops-image-cortex-version" {
  type = string
  description = "secops-image-cortex-version"
}

variable "secops-image-cassandra-version" {
  type = string
  description = "secops-image-cassandra-version"
}

variable "secops-image-elasticsearch-version" {
  type = string
  description = "secops-image-elasticsearch-version"
}

variable "secops-image-nginx-version" {
  type = string
  description = "secops-image-nginx-version"
}
