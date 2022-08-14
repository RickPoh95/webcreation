terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

# Create A Resources Group - In Sandbox already have one when we use it, so this part is excluded
# resource "azurerm_resource_group" "vmss" {
#  name     = var.resource_group_name
#  location = var.location
#  tags     = var.tags
# }

resource "azurerm_virtual_network" "minigrocery" {
  name                = "minigrocery-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "minigrocery" {
  name                 = "minigrocery-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.minigrocery.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "minigrocery" {
  name                = "minigrocery-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = var.domain_name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "minigrocery" {
  name                = "minigrocery-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.minigrocery.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.minigrocery.id 
  }
}

resource "azurerm_network_security_group" "minigrocery" {
  name                = "minigrocery-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags

  security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTML"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.minigrocery.id
  network_security_group_id = azurerm_network_security_group.minigrocery.id
}

resource "azurerm_availability_set" "minigrocery" {
  name                = "minigrocery-availabilityset"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_virtual_machine" "minigrocery" {
  name                = "minigrocery-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  vm_size             = "Standard_D2s_v3"
  tags                = var.tags
  network_interface_ids = [
    azurerm_network_interface.minigrocery.id,
  ]

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "minigrocerydisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "minigrocery-hostname"
    admin_username = var.admin_user
    admin_password = var.admin_password
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
}

#----------output file to repo--------------
resource "local_file" "publicip" {
  content         = azurerm_public_ip.minigrocery.ip_address
  filename        = "./publicip"
  file_permission = "0644"
}

resource "local_file" "DNS" {
  content         = azurerm_public_ip.minigrocery.fqdn
  filename        = "./DNS"
  file_permission = "0644"
}

resource "local_file" "password" {
  content         = var.admin_password
  filename        = "./password"
  file_permission = "0644"
}