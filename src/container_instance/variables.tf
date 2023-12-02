variable "tfstate_resource_group" {
  description = "terraform state resource group"
  type        = string
  sensitive   = true
}

variable "tfstate_storage_account" {
  description = "terraform state storage account"
  type        = string
  sensitive   = true
}

variable "tfstate_storage_account_container" {
  description = "terraform state storage account container name"
  type        = string
  sensitive   = true
}

variable "trading_bot_container_image" {
  description = "trading bot container image"
  type        = string
  sensitive   = true
}

variable "trading_bot_storage_account" {
  description = "trading bot storage account name"
  type        = string
  sensitive   = true
}

variable "trading_bot_resource_group" {
  description = "trading bot resource group name"
  type        = string
  sensitive   = true
}

variable "trading_bot_keyvault" {
  description = "trading bot keyvault name"
  type        = string
  sensitive   = true
}