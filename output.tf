output "gitlab_public_ip" {
  value = azurerm_public_ip.minigrocery.ip_address
}

output "DNS_name" {
  value = azurerm_public_ip.minigrocery.fqdn
}