# // --------------------------------------------------------- //
# Firewalls and WAFs run different Algorithms –
# WAFs run Anomaly Detection Algorithms, Heuristic Algorithms, and Signature Based Algorithms. 
# Standard Firewalls run Proxy Algorithms, Packet-Filtering Algorithms and Stateless/ Stateful Inspection Algorithms
# AZ Firewall == WAF
# Ref: https://jakewalsh.co.uk/deploying-and-configuring-azure-firewall-using-terraform/
#      https://github.com/kumarvna/terraform-azurerm-firewall
#
# // --------------------------------------------------------- //
resource "azurerm_public_ip" "fw01-pip" {
  name                = "${var.region}-fw01-pip"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

#Azure Firewall Instance
resource "azurerm_firewall" "fw01" {
  name                = "${var.region}-fw01"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku_tier            = var.sku_tier
  sku_name            = var.sku_name
  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.fw01-pip.id
  }

  # dns_servers – Azure Firewall can proxy DNS traffic to specified DNS servers. Provide a list of the DNS servers using this argument.
  # threat_intel_model – This allows the selection of the mode for the threat intelligence filtering system. Values here are Off, Alert, or Deny.
}


## TODO: Firewall Policies


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy
resource "azurerm_firewall_policy" "example" {
  name                = "example-policy"
  resource_group_name = var.resource_group_name
  location            = var.region
  # sku - (Optional) The SKU Tier of the Firewall Policy. Possible values are Standard, Premium and Basic. Changing this forces a new Firewall Policy to be created.
  # threat_intelligence_allowlist - (Optional) A threat_intelligence_allowlist block
  # rule_collection_groups = []
}

## TODO: Policy Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "firewall_policy_rule_collection_group" {
  name               = "example-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.example.id
  priority           = 500
  application_rule_collection {
    name     = "app_rule_collection1"
    priority = 500
    action   = "Deny"
    rule {
      name = "app_rule_collection1_rule1"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.0.0.1"]
      destination_fqdns = ["*.microsoft.com"]
    }
  }

  network_rule_collection {
    name     = "network_rule_collection1"
    priority = 400
    action   = "Deny"
    rule {
      name                  = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.0.1"]
      destination_addresses = ["192.168.1.1", "192.168.1.2"]
      destination_ports     = ["80", "1000-2000"]
    }
  }

  nat_rule_collection {
    name     = "nat_rule_collection1"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "nat_rule_collection1_rule1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["10.0.0.1", "10.0.0.2"]
      destination_address = "192.168.1.1"
      destination_ports   = ["80"]
      translated_address  = "192.168.0.1"
      translated_port     = "8080"
    }
  }
}


#  resource "azurerm_firewall_policy_rule_collection_group" "example" {
#    name               = "example-fwpolicy-rcg"
#    firewall_policy_id = azurerm_firewall_policy.example.id
#    priority           = 500
#    network_rule_collection {
#      name     = "network_rule_collection1"
#      priority = 400
#      action   = "Deny"
#      rule {
#        name                  = "network_rule_collection1_rule1"
#        protocols             = ["TCP", "UDP"]
#        source_addresses      = []
#        destination_addresses = []
#        destination_ports     = ["80"]
#        source_ip_groups      = ["/subscriptions/xxx/resourceGroups/xxxRG/providers/Microsoft.Network/ipGroups/sipgxxx"]
#        destination_ip_groups = ["/subscriptions/xxx/resourceGroups/xxxRG/providers/Microsoft.Network/ipGroups/dipgxxx"]
#      }
#    }
