output "sql_server_fqdn" {
  value = azurerm_sql_server.main.fully_qualified_domain_name
}

output "database_name" {
  value = azurerm_sql_database.main.name
}

output "app_service_name" {
  value = azurerm_app_service.main.name
}

output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.main.default_site_hostname}"
}

output "connection_string" {
  description = "Connection string for the Azure SQL Database created."
  value       = "Server=tcp:${azurerm_sql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.main.name};Persist Security Info=False;User ID=${azurerm_sql_server.main.administrator_login};Password=${azurerm_sql_server.main.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

output "mssql-cli" {
  description = "Connect to SQL Server using mssql-cli"
  value       = "mssql-cli -S ${azurerm_sql_server.main.fully_qualified_domain_name} -d ${azurerm_sql_database.main.name} -U ${azurerm_sql_server.main.administrator_login} -P ${azurerm_sql_server.main.administrator_login_password}"
}