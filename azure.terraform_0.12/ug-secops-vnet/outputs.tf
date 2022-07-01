output "secops-bastion-public-ip" {
  value = azurerm_public_ip.secops-bastion-public-ip.ip_address
}

output "secops-public-dns-record-appgw-thehive" {
  value = azurerm_dns_a_record.secops-dns-record-appgw-thehive.fqdn
}

output "secops-public-dns-record-appgw-cortex" {
  value = azurerm_dns_a_record.secops-dns-record-appgw-cortex.fqdn
}

