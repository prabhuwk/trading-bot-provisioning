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