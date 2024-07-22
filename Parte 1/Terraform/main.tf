// Indicamos el Provider (Azure Resource Manager)
provider "azurerm" {
  features {} 
}

// Creamos un Resource Group donde agruparemos todos los recursos de la solucion
resource "azurerm_resource_group" "rg" {
  name     = "RgUnirJdcr"
  location = "West Europe"
}

// Creamos el Azure Container Registry donde alojaremos las imagenes de nuestro sistema
resource "azurerm_container_registry" "acr" {
  name                = "AcrUnirJdcr"
  resource_group_name = azurerm_resource_group.rg.name          // Va a pertenecer al resource group que creamos en el punto anterior
  location            = azurerm_resource_group.rg.location      // Ponemos la misma location que el resource group
  sku                 = "Basic"                                 // Sirve para indicar la membresia que le queremos dar al ACR (esta es la basica pero existe Standard y Premium)
  admin_enabled       = true                                    // Permite al usuario admin autenticarse
}

// Creamos una red virtual
resource "azurerm_virtual_network" "vnet" {
  name                = "VnetUnirJdcrCp2"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

// Creamos una subred
resource "azurerm_subnet" "subnet" {
  name                 = "SubnetUnirJdcrCp2Vm1"
  resource_group_name  = azurerm_resource_group.rg.name
  //location            = azurerm_resource_group.rg.location // Pense que lo llevaria como los demas, pero no :)
  virtual_network_name = azurerm_virtual_network.vnet.name  
  address_prefixes     = ["10.0.1.0/24"]
}

# Creamos la ip publica
resource "azurerm_public_ip" "public_ip" {
  name                = "PipUnirJdcrCp2Vm1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic" // La ip es asignada de manera dinámica
}

# Creamos la interfaz de red
resource "azurerm_network_interface" "nic" {
  name                = "NicUnirJdcrCp2Vm1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-vm1-conf-cp2-jdcr-unir"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Creamos la maquina virtual
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "Vm1UnirJdcrCp2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" // 1vCPU 1gRam casi 9$/Mes
  
  disable_password_authentication = true
  admin_username      = "jdcr"
  // Esto sería una forma insegura de hacerlo
  //admin_password      = ""

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" // Cuando ejecuto el comando "az vm image list-skus --offer UbuntuServer --publisher canonical --location westeurope --output table" es la mayor LTS que me aparece aunque en el web me aparecen otras ...
    version   = "latest"
  }

  computer_name  = "VM1-JDCR"
  admin_ssh_key {
    username   = "jdcr"
    public_key = file("./keys/id_rsa.pub")    
  }


}