# Location to create resources
variable "location" {
    type = string
}

# Resource group for all resources
variable "resource_group" {
    type = string
}

# Storage Account name
variable "storage_account_name" {
    type = string
}

# Resource tags
variable "tags" {
    type = map
}