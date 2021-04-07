variable "location" {
  description = "The Azure Region in which all resources in this example should be created"
  default = "westeurope"
}

variable "sql_admin_username" {
  description = "Admin username for SQL server"
  default = "DoNotUseThisAdm1n"
}

variable "sql_admin_password" {
  description = "Admin password for SQL server"
  default = "DoNotUseThisP455w0rd"
}