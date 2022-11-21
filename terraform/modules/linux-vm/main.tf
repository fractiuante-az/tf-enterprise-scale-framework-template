resource "random_integer" "ri" {
  min = 1000
  max = 9999
  keepers = {
    vm_name = var.vm_name
  }
}

resource "tls_private_key" "rsa-4096" {
  count     = var.auto_generate_tls_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_sensitive_file" "ssh_private_key" {
  count    = var.auto_generate_tls_key ? 1 : 0
  content  = tls_private_key.rsa-4096.0.private_key_openssh
  filename = "./.ssh/azure_lnx_vm_id_rsa"
}

# Do i really need a public IP --> Some sort of Gateway or DNS on Hub network?!
resource "azurerm_public_ip" "vm_pub_ip" {
  name                = "${random_integer.ri.keepers.vm_name}-public-ip-${random_integer.ri.result}"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pub_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "lnx_vm" {
  name                = var.vm_name
  location            = var.region
  resource_group_name = var.resource_group_name
  size                = var.instance_type
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.auto_generate_tls_key ? trimspace(tls_private_key.rsa-4096.0.public_key_openssh) : file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
