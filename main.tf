provider "azurerm" {
  features {}
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = "East US"  # Change as needed
  resource_group_name = "kml_rg_main-ae6265c9dc754944"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "win2022-ds1"
  location              = "East US"  # Change as needed
  resource_group_name   = "kml_rg_main-ae6265c9dc754944"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "win2022-osdisk"
    caching          = "ReadWrite"
    create_option    = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "win2022vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd123!"  # Change this securely
  }

  os_profile_windows_config {
    enable_automatic_updates = true
  }
}