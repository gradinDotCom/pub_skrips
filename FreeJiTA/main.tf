terraform {
  # required_version   = ">=0.12.8"
}

provider "azurerm" {
  #   version         = ">=1.36"

  features {}
}

module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

variable "nsg" {

}

variable "resource_group_name" {

}

variable "name" {

}

resource "azurerm_network_security_rule" "this" {
  name                        = "allow SSH from ${var.name}"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = module.myip.address
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.nsg
}