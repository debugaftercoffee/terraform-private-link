variable "tags" {
  type = map
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
}

variable "vnet_id" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "ple_source_id" {
    type = string
}

variable "ple_connection_name" {
    type = string
}

variable "ple_subresource_names" {
    type = list
}

variable dns_name {
    type = string
}

# Create a Private DNS Zone for the PLE
resource "azurerm_private_dns_zone" "ple_dns_zone" {
  name                = var.dns_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link DNS Zone to the configured VNET
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_vnet_link" {
  name                  = "vnet_link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ple_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = "false"
  tags                  = var.tags
}

# Create a PLE to the in the configured VNET and link the Private DNS Zone
resource "azurerm_private_endpoint" "ple" {
  name                 = var.ple_connection_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_id            = var.subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.ple_dns_zone.id]
  }

  private_service_connection {
    name                           = var.ple_connection_name
    is_manual_connection           = false
    private_connection_resource_id = var.ple_source_id
    subresource_names              = var.ple_subresource_names
  }
}

# Output the resource id of the private endpoint
output "ple_id" {
  value = azurerm_private_endpoint.ple.id
}

# Output the resource id of the private dns zone
output "private_dns_id" {
  value = azurerm_private_dns_zone.ple_dns_zone.id
}