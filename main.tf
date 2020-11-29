# Configure the provider
provider "azurerm" {
  version = ">=2"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
  tags     = var.tags
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  address_space       = ["10.253.0.0/22"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Create a subnet private endpoints
resource "azurerm_subnet" "ple-subnet" {
  name                 = "ple-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.253.0.0/25"]
  enforce_private_link_endpoint_network_policies = true
}

# Storage Account only accessible from private link
resource "azurerm_storage_account" "storage" {
  name                      = var.storage_account_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  access_tier               = "Cool"
  enable_https_traffic_only = true

  network_rules {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]
  }

  tags = var.tags
}

# Create an Private Endpoint to the Storage and create a Private DNS Zone
# for the Private Endpoints private IP address
module "storage_private_endpoint_dns_zone" {
  source = "./modules/private_endpoint_with_dns"

  tags                  = var.tags
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  vnet_id               = azurerm_virtual_network.vnet.id
  subnet_id             = azurerm_subnet.ple-subnet.id
  ple_source_id         = azurerm_storage_account.storage.id
  ple_connection_name   = "storage-ple"
  ple_subresource_names = ["blob"]
  dns_name              = "privatelink.blob.core.windows.net"
}

output "ple_id" {
  value = module.storage_private_endpoint_dns_zone.ple_id
}

output "private_dns_id" {
  value = module.storage_private_endpoint_dns_zone.private_dns_id
}