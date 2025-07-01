resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = data.azurerm_key_vault_secret.vm_username.value
  admin_password                  = data.azurerm_key_vault_secret.vm_password.value
  disable_password_authentication = false
  network_interface_ids = [data.azurerm_network_interface.data_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher 
    offer     = var.image_offer     
    sku       = var.image_sku       
    version   = var.image_version   
      }
  custom_data = var.custom_data
}

data "azurerm_network_interface" "data_nic" {
  name                = var.nic_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "vm_username" {
  name         = var.username_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
  depends_on   = [data.azurerm_key_vault.kv]
}

data "azurerm_key_vault_secret" "vm_password" {
  name         = var.password_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
  depends_on   = [data.azurerm_key_vault.kv]
}

