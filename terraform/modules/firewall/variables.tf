variable "tags" {
  default = {}
}
variable "resource_group_name" {
  type = string
}
variable "region" {
  type = string
}
variable "subnet_id" {
  type        = string
  description = "Firewall subnet resource ID"
}
variable "sku_tier" {
  default     = "Premium" # Premium required for more options filter 
  description = "Standard or Premium"
  type        = string
}
variable "sku_name" {
  # description = "options are AZFW_Hub or AZFW_VNet"
  default = "AZFW_VNet"
}
