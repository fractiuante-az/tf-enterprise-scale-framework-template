
output "vm_pub_ip" {
  value = azurerm_public_ip.vm_pub_ip.fqdn
}

