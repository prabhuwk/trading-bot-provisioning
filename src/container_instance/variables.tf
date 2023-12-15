variable "trading_bot_container_registry" {
  description = "trading bot container registry name"
  type        = string
  sensitive   = true
}

variable "trading_bot_container_registry_username" {
  description = "trading bot container registry username"
  type        = string
  sensitive   = true
}

variable "trading_bot_container_registry_password" {
  description = "trading bot container registry password"
  type        = string
  sensitive   = true
}

variable "trading_bot_storage_account" {
  description = "trading bot storage account name"
  type        = string
  sensitive   = true
}

variable "trading_bot_storage_account_key" {
  description = "trading bot storage account access key"
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

variable "trading_bot_keyvault_url" {
  description = "trading bot keyvault url"
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "log analytics workspace id"
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_key" {
  description = "log analytics workspace key"
  type        = string
  sensitive   = true
}