data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_secret" "kv_secrets" {
  name         = var.secret_name
  value        = var.secret_value
  key_vault_id = data.azurerm_key_vault.kv.id
  depends_on = [ data.azurerm_key_vault.kv ]
}


