provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    key                   = "container_instance/terraform.tfstate"
  }
}


resource "azurerm_resource_group" "trading_bot_rg" {
  for_each = var.indexes
  name     = "${each.value}-trading-bot"
  location = "Central India"
}

resource "azurerm_container_group" "trading_bot_acg" {
  for_each = var.indexes
  name                = "${each.value}-trading-bot"
  location            = azurerm_resource_group.trading_bot_rg["${each.value}"].location
  resource_group_name = azurerm_resource_group.trading_bot_rg["${each.value}"].name
  os_type             = "Linux"

  init_container {
    name = "download-symbol-file"
    image = "${var.trading_bot_container_registry}/trading-bot/download-symbol-file:v1.0"
    commands = ["/bin/sh", "-c", "./download_symbol_file.sh"]
    environment_variables = {
      "DOWNLOAD_URL" = "https://images.dhan.co/api-data/api-scrip-master.csv"
      "DOWNLOAD_DIR" = "/download"
      "SYMBOL_NAME" = "${each.value}"
    }
    volume {
        name = "download"
        mount_path = "/download"
        empty_dir = true
    }
  }

  container {
    name   = "${each.value}-chart-data-collector"
    image  = "${var.trading_bot_container_registry}/trading-bot/chart-data-collector:v1.1"
    cpu    = "2"
    memory = "0.5"

    volume {
      name = "download"
      mount_path = "/download"
      empty_dir = true
    }

    volume {
      name = "upload"
      mount_path = "/upload"
      read_only = false
      share_name = "trading-bot-fileshare"
      storage_account_name = var.trading_bot_storage_account
      storage_account_key = var.trading_bot_storage_account_key
    }

    secure_environment_variables = {
      "KEYVAULT_URL" = var.trading_bot_keyvault_url
    }

    environment_variables = {
      "TZ" = "Asia/Kolkata"
      "REDIS_HOST" = "localhost"
      "REDIS_PORT" = "6379"
    }

    commands = ["/bin/bash", "-c", "sleep 60;python src/main.py --symbol-name ${each.value} --exchange NSE --environment production"]
    # enable following for troubleshooting only
    # commands = ["/bin/bash", "-c", "sleep 10000"]
  }

  container {
    name   = "${each.value}-order-management"
    image  = "${var.trading_bot_container_registry}/trading-bot/order-management:v1.1"
    cpu    = "1"
    memory = "0.5"

    volume {
      name = "download"
      mount_path = "/download"
      empty_dir = true
    }

    secure_environment_variables = {
      "KEYVAULT_URL" = var.trading_bot_keyvault_url
    }

    environment_variables = {
      "TZ" = "Asia/Kolkata"
      "REDIS_HOST" = "localhost"
      "REDIS_PORT" = "6379"
    }

    commands = ["/bin/bash", "-c", "sleep 60;python src/main.py --symbol-name ${each.value} --exchange NSE --environment production"]
    # enable following for troubleshooting only
    # commands = ["/bin/bash", "-c", "sleep 10000"]
  }

  container {
    name = "${each.value}-redis-queue"
    image = "${var.trading_bot_container_registry}/trading-bot/redis:latest"
    cpu = "1"
    memory = "0.5"

    ports {
      port = 6379
      protocol = "TCP"
    }

    environment_variables = {
      "REDIS_HOST" = "localhost"
      "REDIS_PORT" = "6379"
    }
  }
  
  image_registry_credential {
    server   = var.trading_bot_container_registry
    username = var.trading_bot_container_registry_username
    password = var.trading_bot_container_registry_password
  }

  ip_address_type = "None"

  identity {
    type = "SystemAssigned"
  }
  
  diagnostics {
    log_analytics {
      workspace_id = var.log_analytics_workspace_id
      workspace_key = var.log_analytics_workspace_key
    }
  }
}

data "azurerm_key_vault" "trading_bot_keyvault" {
  name                = var.trading_bot_keyvault
  resource_group_name = var.trading_bot_resource_group
}

resource "azurerm_key_vault_access_policy" "trading_bot_keyvault_access_policy" {
  for_each = var.indexes
  key_vault_id = data.azurerm_key_vault.trading_bot_keyvault.id

  tenant_id = data.azurerm_key_vault.trading_bot_keyvault.tenant_id
  object_id = azurerm_container_group.trading_bot_acg["${each.value}"].identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}
