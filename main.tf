provider "azurerm" {
  features {}
}

# Variables for reusability
variable "resource_group_name" {
  default = "kml_rg_main-ae6265c9dc754944"
}

variable "location" {
  default = "East US"
}

variable "admin_username" {
  default = "adminuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "vnet_name" {
  default = "main-vnet"
}

variable "subnet_name" {
  default = "subnet1"
}

variable "vm_name" {
  default = "win2022-ds1"
}

variable "vm_size" {
  default = "Standard_DS1_v2"
}

variable "private_ip_allocation" {
  default = "Dynamic"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = var.private_ip_allocation
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  vm_size               = var.vm_size

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    enable_automatic_updates = true
  }

  depends_on = [azurerm_network_interface.vm_nic]
}
