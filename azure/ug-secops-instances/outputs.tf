output "secops-private-dns-record-thehive" {
  value = azurerm_private_dns_a_record.secops-private-dns-thehive-record.fqdn
}

output "secops-thehive-private-ip" {
  value = azurerm_network_interface.secops-nic-thehive.private_ip_address
}

output "secops-private-dns-record-cortex" {
  value = azurerm_private_dns_a_record.secops-private-dns-cortex-record.fqdn
}

output "secops-cortex-private-ip" {
  value = azurerm_network_interface.secops-nic-cortex.private_ip_address
}