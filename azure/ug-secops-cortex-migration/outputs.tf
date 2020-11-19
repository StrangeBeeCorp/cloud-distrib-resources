output "secops-private-dns-record-cortex" {
  value = azurerm_private_dns_a_record.secops-private-dns-cortex-record.fqdn
}

output "secops-cortex-private-ip" {
  value = azurerm_network_interface.secops-nic-cortex.private_ip_address
}