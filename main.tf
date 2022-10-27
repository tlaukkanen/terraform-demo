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

resource "azurerm_monitor_autoscale_setting" "main" {
  name = "asp-terraform-autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  target_resource_id = azurerm_app_service_plan.main.id
  profile {
    name = "default"
    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }
    // Increase rule
    rule {
      metric_trigger {
        metric_name = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.main.id
        time_grain = "PT1M" // 1 minute period
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "GreaterThan"
        threshold = 80
      }
      scale_action {
        direction = "Increase"
        type = "ChangeCount"
        cooldown = "PT10M"
        value = "1"
      }
    }
    // Decrease rule
    rule {
      metric_trigger {
        metric_name = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.main.id
        time_grain = "PT1M" // 1 minute period
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "LessThan"
        threshold = 20
      }
      scale_action {
        direction = "Decrease"
        type = "ChangeCount"
        cooldown = "PT10M"
        value = "1"
      }
    }
  }
  notification {
    email {
      // send_to_subscription_administrator = true
      // send_to_subscription_co_administrator = true
      // Send email to custom address, for example Teams channel
      custom_emails = [ "first.last@domain.com" ]
    }
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