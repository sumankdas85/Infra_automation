data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "sql_user" {
  name         = var.sql_user_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
  depends_on   = [data.azurerm_key_vault.kv] 
}

data "azurerm_key_vault_secret" "sql_password" {
  name         = var.sql_pwd_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
  depends_on   = [data.azurerm_key_vault.kv] 
}
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.sql_user.value
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value
}