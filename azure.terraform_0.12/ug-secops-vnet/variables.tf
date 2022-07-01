variable "secops-resource-group-name" {
  type = string
  description = "secops resource group name"
}
variable "secops-dns-resource-group-name" {
  type = string
  description = "secops resource group name for DNS public zone (in case it is shared with other resources)"
}
variable "secops-location" {
  type = string
  description = "secops Azure Location"
}
variable "secops-virtual-network-name" {
  type = string
  description = "secops Virtual Network name"
}
variable "secops-appgw-frontend-public-subnet-name" {
  type = string
  description = "App Gateway subnet name"
}
variable "secops-backend-private-subnet-name" {
  type = string
  description = "Backend private subnet name"
}
variable "secops-public-subnet-name" {
  type = string
  description = "Public subnet name (bastion)"
}
variable "secops-vnet" {
  type = string
  description = "secops Virtual Network CIDR Block"
}
variable "secops-appgw-frontend-public-subnet" {
  type = string
  description = "secops Public Azure Application Gateway Subnet CIDR"
}
variable "secops-backend-private-subnet" {
  type = string
  description = "secops backend private Subnet CIDR"
}
variable "secops-public-subnet" {
  type = string
  description = "secops public Subnet CIDR"
}
variable "secops-bastion-public-ip-name" {
  type = string
  description = "Bastion public ip name"
}
variable "secops-myNVA-public-ip-name" {
  type = string
  description = "myNVA public ip name"
}
variable "secops-appgw-public-ip-name" {
  type = string
  description = "App Gateway public ip name"
}
variable "secops-dns-zone-name" {
  type = string
  description = "secops DNS zone in Azure DNS"
}
variable "secops-private-zone-name" {
  type = string
  description = "secops DNS private zone in Azure DNS"
}
variable "secops-bastion-computer-name" {
  type = string
  description = "Bastion instance name"
}
variable "secops-bastion-vm-size" {
  type = string
  description = "Bastion VM size"
}
variable "secops-bastion-admin-user" {
  type = string
  description = "Admin user for bastion"
}
variable "secops-bastion-public-key-path" {
  type = string
  description = "Path for public key for bastion"
}
variable "secops-myNVA-computer-name" {
  type = string
  description = "myNVA instance name"
}
variable "secops-myNVA-vm-size" {
  type = string
  description = "myNVA VM size"
}
variable "secops-myNVA-admin-user" {
  type = string
  description = "Admin user for myNVA"
}
variable "secops-myNVA-public-key-path" {
  type = string
  description = "Path for public key for myNVA"
}
variable "secops-os-disk-type" {
  type = string
  description = "secops-os-disk-type"
}
variable "secops-users" {
  type = list
  description = "Secops users IP whitelist"
}
variable "secops-key-vault-name" {
  type = string
  description = "secops-key-vault-name"
}
variable "thehive_key_vault_certificate_secret_id" {
  type = string
  description = "Secret ID for TheHive certificate - set as env variable, not in code"
}
variable "cortex_key_vault_certificate_secret_id" {
  type = string
  description = "Secret ID for Cortex certificate - set as env variable, not in code"
}

# variable "" {
#   type = string
#   description = ""
# }
