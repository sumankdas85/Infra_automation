module "sumankaresource" {
  source                  = "../Child_module/Azurerm_RG"
  resource_group_name     = "new_rg"
  resource_group_location = "eastus"

}

module "virtual_network" {
  depends_on          = [module.sumankaresource]
  source              = "../Child_module/Azurerm_Vnet"
  vnet_name           = "myvnet"
  location            = "eastus"
  resource_group_name = "new_rg"
  address_space       = ["10.0.0.0/16"]
}

module "subnet" {
  depends_on          = [module.virtual_network]
  source              = "../Child_module/Azurerm_Subnet"
  subnet_name         = "suman_subnet"
  resource_group_name = "new_rg"
  vnet_name           = "myvnet"
  address_prefixes    = ["10.0.2.0/24"]
}


module "pip" {
  source              = "../Child_module/Azurerm_PIP"
  public_ip_name      = "pip_suman"
  location            = "eastus"
  resource_group_name = "new_rg"
  allocation_method   = "Static"

}


module "nic" {
  depends_on          = [module.subnet, module.pip]
  source              = "../Child_module/Azurerm_Nic"
  nic_name            = "suman_nic"
  location            = "eastus"
  resource_group_name = "new_rg"
  vnet_name           = "myvnet"
  pip_name            = "pip_suman"
  subnet_name         = "suman_subnet"
}

module "virtual_machine" {
  depends_on           = [module.subnet, module.kv_module]
  source               = "../Child_module/Azurerm_VM"
  resource_group_name  = "new_rg"
  location             = "eastus"
  vm_name              = "frontend-vm"
  vm_size              = "Standard_F2"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "suman_nic"
  username_secret_name = "vmusername"
  password_secret_name = "vmpassword"
  kv_name              = "skkvault"

  custom_data = base64encode(<<EOF
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
EOF
  )
}


module "backend_virtual_machine" {
  depends_on           = [module.subnet, module.kv_module]
  source               = "../Child_module/Azurerm_VM"
  resource_group_name  = "new_rg"
  location             = "eastus"
  vm_name              = "backend-vm"
  vm_size              = "Standard_F2"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "suman_nic"
  username_secret_name = "vmusername"
  password_secret_name = "vmpassword"
  kv_name              = "skkvault"
}


module "sqlserver_module" {
  depends_on           = [module.kv_module]
  source               = "../Child_module/Sql_server"
  sql_server_name      = "sumann-sql-server"
  resource_group_name  = "new_rg"
  location             = "centralindia"
  kv_name              = "skkvault"
  sql_user_secret_name = "sqladminuser"
  sql_pwd_secret_name  = "sqlpassword"
}

module "db_module" {
  depends_on          = [module.sqlserver_module]
  source              = "../Child_module/Sql_database"
  resource_group_name = "new_rg"
  server_name         = "sumann-sql-server"
  db_name             = "mydatabase"
}

module "kv_module" {
  source              = "../Child_module/Azurerm_Keyvault"
  kv_name             = "skkvault"
  location            = "Centralindia"
  resource_group_name = "new_rg"

}
module "vm_username" {
  depends_on          = [module.kv_module]
  source              = "../Child_module/Azurerm_kv_secret"
  kv_name             = "skkvault"
  resource_group_name = "new_rg"
  secret_name         = "vmusername"
  secret_value        = "Administrator"

}

module "vm_pwd" {
  depends_on          = [module.kv_module]
  source              = "../Child_module/Azurerm_kv_secret"
  kv_name             = "skkvault"
  resource_group_name = "new_rg"
  secret_name         = "vmpassword"
  secret_value        = "Password@987"

}

module "sql_user" {
  depends_on          = [module.kv_module]
  source              = "../Child_module/Azurerm_kv_secret"
  kv_name             = "skkvault"
  resource_group_name = "new_rg"
  secret_name         = "sqlusername"
  secret_value        = "adminuser"

}
module "sql_pwd" {
  depends_on          = [module.kv_module]
  source              = "../Child_module/Azurerm_kv_secret"
  kv_name             = "skkvault"
  resource_group_name = "new_rg"
  secret_name         = "sqlpassword"
  secret_value        = "Password@859"

}