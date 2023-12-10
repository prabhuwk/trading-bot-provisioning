provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    key                   = "container_instance/terraform.tfstate"
  }
}


resource "azurerm_resource_group" "test_trading_bot" {
  name     = "test-trading-bot"
  location = "Central India"
}

resource "azurerm_container_group" "test_trading_bot_banknifty" {
  name                = "test-trading-bot-banknifty"
  location            = azurerm_resource_group.test_trading_bot.location
  resource_group_name = azurerm_resource_group.test_trading_bot.name
  os_type             = "Linux"

  init_container {
    name = "download-symbol-file"
    image = "${var.trading_bot_container_registry}/bots/download-symbol-file:v1.0"
    commands = ["/bin/sh", "-c", "./download_symbol_file.sh"]
    environment_variables = {
      "DOWNLOAD_URL" = "https://images.dhan.co/api-data/api-scrip-master.csv"
      "DOWNLOAD_DIR" = "/download"
    }
    volume {
        name = "download"
        mount_path = "/download"
        empty_dir = true
    }
  }

  container {
    name   = "test-trading-bot-banknifty"
    image  = "${var.trading_bot_container_registry}/bots/trading-bot:v1.1"
    cpu    = "4"
    memory = "2"

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
    }

    commands = [ "/bin/bash", "-c", "python src/main.py --symbol-name BANKNIFTY --exchange IDX --environment production" ]
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
}

data "azurerm_storage_account" "trading_bot_storage_account" {
  name                = var.trading_bot_storage_account
  resource_group_name = var.trading_bot_resource_group
}

data "azurerm_key_vault" "trading_bot_keyvault" {
  name                = var.trading_bot_keyvault
  resource_group_name = var.trading_bot_resource_group
}


resource "azurerm_role_assignment" "storage_access" {
  scope                = data.azurerm_storage_account.trading_bot_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_container_group.test_trading_bot_banknifty.identity[0].principal_id
}


resource "azurerm_key_vault_access_policy" "trading_bot_keyvault_access_policy" {
  key_vault_id = data.azurerm_key_vault.trading_bot_keyvault.id

  tenant_id = data.azurerm_key_vault.trading_bot_keyvault.tenant_id
  object_id = azurerm_container_group.test_trading_bot_banknifty.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}
