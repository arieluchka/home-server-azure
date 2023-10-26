terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "server_resource" {
  name     = "${var.server_name}-resource"
  location = var.location
}

resource "azurerm_virtual_network" "server_vnet" {
  name                = "${var.server_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.server_resource.name
}

resource "azurerm_subnet" "server_subnet" {
  name                 = "${var.server_name}-subnet1"
  resource_group_name  = azurerm_resource_group.server_resource.name
  virtual_network_name = azurerm_virtual_network.server_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "server_nsg" {
  name                = "${var.server_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.server_resource.name
}

resource "azurerm_network_security_rule" "allow22" {
  name = "allow-22"
  priority = 150
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = ["22", "80", "443", "3389"]
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.server_resource.name
  network_security_group_name = azurerm_network_security_group.server_nsg.name
}

resource "azurerm_public_ip" "server_pip" {
  name                    = "${var.server_name}-pip"
  location                = var.location
  resource_group_name     = azurerm_resource_group.server_resource.name
  allocation_method       = "Static"
}

resource "azurerm_network_interface" "server_nic" {
  name                = "${var.server_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.server_resource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.server_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.server_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "server_vm" {
  depends_on = [  ]
  name                = "${var.server_name}-vm"
  resource_group_name = azurerm_resource_group.server_resource.name
  location            = var.location
  size                = "Standard_D3_v2"
  admin_username      = var.server_username
  admin_password = var.server_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.server_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "test_script" {
  depends_on = [ azurerm_linux_virtual_machine.server_vm ]
  name = "ariel-server-script"
  virtual_machine_id = azurerm_linux_virtual_machine.server_vm.id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
    "script": "${base64encode(file("${path.module}//setup-script.bash"))}"
  }
  SETTINGS  
}