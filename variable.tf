variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "<your_resources_group_name>"
}

variable "location" {
  description = "Location where resources will be created"
  default     = "East US"  
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    application = "minigrocery"
  }
}

variable "domain_name" {
  description = "Domain name for minigrocery to access through public ip"
  default     = "minigrocery01"  
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "<your_admin_user_name>"
}

variable "admin_password" {
  description = "Default password for admin account"
  default = "<your_admin_password>"
}