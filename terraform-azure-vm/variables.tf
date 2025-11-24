# Variable definitions for Azure VM deployment

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-terraform-vm"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-terraform-vm"
}

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
  default     = "subnet-terraform-vm"
}

variable "public_ip_name" {
  description = "Name of the Public IP"
  type        = string
  default     = "pip-terraform-vm"
}

variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
  default     = "nsg-terraform-vm"
}

variable "nic_name" {
  description = "Name of the Network Interface Card"
  type        = string
  default     = "nic-terraform-vm"
}

variable "vm_name" {
  description = "Name of the Virtual Machine"
  type        = string
  default     = "vm-terraform-ubuntu"
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the Virtual Machine"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for the Virtual Machine"
  type        = string
  sensitive   = true
}