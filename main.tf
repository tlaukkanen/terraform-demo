terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = "rg-terraform"
  location = "westeurope"  
  tags = {
    Environment = "Lab"
  }
}

resource "azurerm_app_service_plan" "main" {
  name = "asp-terraform"
  location = "westeurope"
  resource_group_name = azurerm_resource_group.rg.name
  kind = "Linux"
  reserved = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "main" {
  name = "app-terraform"
  location = "westeurope"
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  site_config {
    linux_fx_version = "DOTNETCORE|5.0"
    dotnet_framework_version = "v5.0"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name = "Database"
    type = "SQLAzure"   
    value = "Server=tcp:${azurerm_sql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.main.name};Persist Security Info=False;User ID=${azurerm_sql_server.main.administrator_login};Password=${azurerm_sql_server.main.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

resource "azurerm_sql_server" "main" {
  name = "sql-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  version = "12.0"
  administrator_login = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_sql_database" "main" {
  name = "db-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  server_name = azurerm_sql_server.main.name
  edition = "Basic"
  collation = "SQL_Latin1_General_CP1_CI_AS"
  create_mode = "Default"
  requested_service_objective_name = "Basic"
}

# Enables the "Allow Access to Azure services" box as described in the API docs
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_sql_firewall_rule" "azure-services" {
  name                = "allow-azure-srvs"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}