variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "1-37798499-playground-sandbox"
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
  description = "Domain name for gitlab to access through public ip"
  default     = "minigrocery"  
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "apachetest"
}

variable "admin_password" {
  description = "Default password for admin account"
  default = "apache12345!"
}