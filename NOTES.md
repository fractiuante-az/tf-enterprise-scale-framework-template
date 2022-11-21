## TODOs

[ ] Developer access to Jumphost?
[ ] Linux VM connection --> public ip reachable?
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform

[ ] Linux VM via DNS
```
# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

```

[ ] access Flexible PostgresDB from "On-Premise-Net" via DNS Translation

[ ] End-User access to AKS?


## Ref
- https://www.youtube.com/watch?v=ErnP5Yo6NqU&t=17s
