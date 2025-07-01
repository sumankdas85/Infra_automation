variable "resource_group_name" {}
variable "location" {}
variable "vm_name" {}
variable "vm_size" {}
variable "image_publisher" {}
variable "image_offer" {} 
variable "image_sku" {}
variable "image_version" {}
variable "nic_name" {}
variable "username_secret_name" {}
variable "password_secret_name" {}
variable "kv_name" {}
variable "custom_data" {
    type    = string
  default = null
}


  


