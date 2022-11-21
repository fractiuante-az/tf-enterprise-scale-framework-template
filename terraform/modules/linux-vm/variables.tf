variable "region" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "subnet_id" {
  type = string
}

# // --- DEFAULTS ----------------------------- //
variable "auto_generate_tls_key" {
  default = true
  type    = bool
}
variable "instance_type" {
  default = "Standard_F2"
  type    = string
}
variable "admin_username" {
  default = "adminuser"
  type    = string
}
variable "vm_name" {
  default = "my-lnx-vm"
  type    = string
}
