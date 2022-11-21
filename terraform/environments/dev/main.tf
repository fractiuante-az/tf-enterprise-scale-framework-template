# // --------------------------------------------------------- //
#
# Hub and Spoke Model
# Ref: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/decision-guides/software-defined-network/hub-spoke
#  - The hub is a virtual network that acts as a central location for managing external connectivity and hosting services used by multiple workloads. 
#  - The spokes are virtual networks that host workloads and connect to the central hub through virtual network peering.
#
# ++ often used alongside the hybrid networking architecture, providing a centrally managed connection to your on-premises environment shared between multiple workloads
#
# // --------------------------------------------------------- //

locals {
  tags = {
    environment = var.environment
    region      = var.region
  }
  resource_group_name      = lower("${var.resource_group_name}")
  subnet_name_hub_jumphost = "Jumphost"
}

data "azurerm_client_config" "current" {}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

resource "azurerm_resource_group" "main_resource_group" {
  name     = local.resource_group_name
  location = var.region
  tags     = merge(local.tags, { "Module" : "main", "Name" : local.resource_group_name })
}

# https://github.com/Azure/terraform-azurerm-vnet/tree/3.0.0
#
# All Incoming Traffic will be routed through the Hub
# 
module "vnet_hub" {
  vnet_name  = "hub"
  depends_on = [azurerm_resource_group.main_resource_group]
  source     = "Azure/vnet/azurerm"
  version    = "3.0.0"

  resource_group_name = local.resource_group_name
  vnet_location       = var.region
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Jumphost: VM as a bastion/jumphost with IP-Whitelisting
  # VPN for Office(On-Premise)/ Developer --> different ways to authenticate
  subnet_names = ["Firewall", local.subnet_name_hub_jumphost, "VpnGateway"]
  tags         = local.tags
}

module "vnet_spoke" {
  vnet_name  = "spoke-dummy"
  depends_on = [azurerm_resource_group.main_resource_group]
  source     = "Azure/vnet/azurerm"
  version    = "3.0.0"

  resource_group_name = local.resource_group_name
  vnet_location       = var.region
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  # TODO: PrivateEndpoints for KeyVault/ ACR
  subnet_names = ["PrivateEndpoints", "Cluster", "Database"]
  tags         = local.tags
}


resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = local.resource_group_name
  virtual_network_name      = module.vnet_hub.vnet_name
  remote_virtual_network_id = module.vnet_spoke.vnet_id
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = local.resource_group_name
  virtual_network_name      = module.vnet_spoke.vnet_name
  remote_virtual_network_id = module.vnet_hub.vnet_id

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  #   allow_gateway_transit        = false
  #   allow_virtual_network_access = true
  #   allow_forwarded_traffic      = true

}
output "vnet_subnets_map" {
  value = module.vnet_hub.vnet_subnets_name_id
}

module "lnx-vm-jumphost" {
  source              = "../../modules/linux-vm"
  depends_on          = [module.vnet_hub]
  vm_name             = "lnx-vm-hub-jumphost"
  region              = var.region
  resource_group_name = local.resource_group_name
  subnet_id           = lookup(module.vnet_hub.vnet_subnets_name_id, local.subnet_name_hub_jumphost)

}
