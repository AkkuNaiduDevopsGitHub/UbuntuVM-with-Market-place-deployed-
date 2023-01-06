#   taken from trainer 
################# Start ########################
provider "azurerm" {
    skip_provider_registration = true
    features {}
    }
    
    #1st RG
    resource "azurerm_resource_group" "rg01" {
      name = "rg-dev-EastUS-001"
      location = "East US"
      tags = {
        "Environment" = "Dev"
        "Deployed from" = "Devops"
      }
    }

    #2nd RG
    resource "azurerm_resource_group" "rg02" {
      name = "rg-uat-EastUS-001"
      location = "East US"
      tags = {
       "Environment" = "uat"
        "Deployed from" = "Devops"
      }
    }
    #3rd RG
    resource "azurerm_resource_group" "rg03" {
      name = "rg-prod-EastUS-001"
     location = "East US"
      tags = {
       "Environment" = "pord"
        "Deployed from" = "Devops"
      }
    }
    
    #VNET
    resource "azurerm_virtual_network" "vnet01" {
        name = "Vnet-prod-EastUS-001"
        location = "East US"
        resource_group_name = azurerm_resource_group.rg01.name
        address_space       = ["10.30.12.0/22"]
        #dns_servers         = ["172.16.64.68", "172.16.64.69"]
        #ddos_protection_plan {
        #  id = "/subscriptions/939ccbea-0b32-406e-a19c-74827d25670a/resourceGroups/rg-networking-prod-001/providers/Microsoft.Network/ddosProtectionPlans/GTA-DDoS"
        #  enable = "true"
        #}
        tags = {
        "Environment" = "pord"
        "Deployed from" = "Devops"
      }
    }
    
   
    
    #SNET01
    resource "azurerm_subnet" "snet01" {
      name                 = "snet-dev-EastUS-001"
      resource_group_name  = azurerm_resource_group.rg01.name
      virtual_network_name = azurerm_virtual_network.vnet01.name
      address_prefixes     = ["10.30.12.0/24"]
      service_endpoints    = ["Microsoft.AzureActiveDirectory","Microsoft.Storage","Microsoft.KeyVault"]
    }
    
    #SNET02
    resource "azurerm_subnet" "snet02" {
      name                 = "snet-prod-EastUS-001"
      resource_group_name  = azurerm_resource_group.rg01.name
      virtual_network_name = azurerm_virtual_network.vnet01.name
      address_prefixes     = ["10.30.13.0/24"]
      service_endpoints    = ["Microsoft.AzureActiveDirectory","Microsoft.Storage","Microsoft.KeyVault"]
      
    }
    

    #NSG
    
    resource "azurerm_network_security_group" "nsg01" {
      name = "nsg-dev-EastUS-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location = "East US" 
      tags = {
       "Environment" = "pord"
        "Deployed from" = "Devops"
      }
    }
    
    resource "azurerm_network_security_group" "nsg02" {
      name = "nsg-prod-EastUS-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location = "East US" 
      tags = {
       "Environment" = "pord"
        "Deployed from" = "Devops"
      }
    }
    

    
    #NSG Association
    
    resource "azurerm_subnet_network_security_group_association" "nsgas01" {
      subnet_id                 = azurerm_subnet.snet01.id
      network_security_group_id = azurerm_network_security_group.nsg01.id
      depends_on = [azurerm_network_security_group.nsg01
      ]
    }
    
    resource "azurerm_subnet_network_security_group_association" "nsgas02" {
      subnet_id                 = azurerm_subnet.snet02.id
      network_security_group_id = azurerm_network_security_group.nsg02.id
      depends_on = [azurerm_network_security_group.nsg02
      ]
    }
    
    
    #Route tables

   #Route table 1 
    resource "azurerm_route_table" "rt01" {
      name                = "rt-snet-prod-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location            = "East US"
      disable_bgp_route_propagation = "false"
      tags = {
       "Environment" = "pord"
        "Deployed from" = "Devops"
      }
    
            route {
            name = "udr-default_route"
            address_prefix = "0.0.0.0/0"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-hub"
            address_prefix = "10.20.0.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-prod"
            address_prefix = "10.30.8.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }


    }

   #Route table 2
    resource "azurerm_route_table" "rt02" {
      name                = "rt-snet-dev-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location            = "East US"
      disable_bgp_route_propagation = "false"
      tags = {
       "Environment" = "pord"
        "Deployed from" = "Devops"
      }
    
            route {
            name = "udr-default_route"
            address_prefix = "0.0.0.0/0"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-hub"
            address_prefix = "10.20.0.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }

            route {
            name = "udr-to-prod"
            address_prefix = "10.30.8.0/22"
            next_hop_type = "VirtualAppliance"
            next_hop_in_ip_address = "10.20.0.137"
            }
    }
   
    #Route table Association
    
    resource "azurerm_subnet_route_table_association" "rtsubsc01" {
      subnet_id      = azurerm_subnet.snet01.id
      route_table_id = azurerm_route_table.rt01.id
    }
    
    resource "azurerm_subnet_route_table_association" "rtsubsc02" {
      subnet_id      = azurerm_subnet.snet02.id
      route_table_id = azurerm_route_table.rt02.id
    }
    
    #######################################
    ##########   VM Creation  #############
    #######################################


#vm01 creation - akkuterravm

resource "azurerm_network_interface" "vm01nic01" {
   name                = "nic-akkuterravm"
   location            = azurerm_resource_group.rg01.location
   resource_group_name = "rg-dev-EastUS-001"

    ip_configuration {
     name                          = "ipconfig01"
     subnet_id                     = azurerm_subnet.snet01.id
     private_ip_address_allocation = "Static"
     private_ip_address = "10.30.12.7"
     primary =  "true"
    }
    tags = {
    "Environment" = "pord"
        "Deployed from" = "Devops"
  }
    /*  ip_configuration {
     name                          = "ipconfig02"
     subnet_id                     = data.azurerm_subnet.snet01.id
     private_ip_address_allocation = "Static"
     private_ip_address = "172.16.74.69"
    }
    */
}

resource "azurerm_linux_virtual_machine" "vm01" {
  name                  = "akkuterravm"
  location              = azurerm_resource_group.rg01.location
  resource_group_name   = "rg-dev-EastUS-001"
  network_interface_ids = [azurerm_network_interface.vm01nic01.id]
  size                  = "Standard_D8as_v5"
  admin_username        = "akkumadmin"
  admin_password        = "jmgf*I!pe@0T5W#z8e"
  disable_password_authentication = false
  license_type                 = "SLES_BYOS"
  tags = {
     "Environment" = "pord"
        "Deployed from" = "Devops"
  }
  
 

  source_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "18.04-LTS"
     version   = "latest"
   }

  os_disk {
    name          = "akkuterravm-osdisk"
    disk_size_gb    = "64"
    caching       = "ReadWrite"
    storage_account_type = "Premium_LRS"
    #
  }
}

#vm01 Datadisk01
resource "azurerm_managed_disk" "vm01dd01" {
  name                 = "akkuterravm-datadisk-01"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-dev-EastUS-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "40"
  tags = {
     "Environment" = "pord"
        "Deployed from" = "Devops"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd01att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd01.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "0"
  caching            = "ReadWrite"
  #write_accelerator_enabled = "true"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd01
  ]
}
#vm01 Datadisk02
resource "azurerm_managed_disk" "vm01dd02" {
  name                 = "akkuterravm-datadisk-02"
  location             = azurerm_resource_group.rg01.location
  resource_group_name  = "rg-dev-EastUS-001"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  tags = {
     "Environment" = "pord"
        "Deployed from" = "Devops"
  }
  
  }
resource "azurerm_virtual_machine_data_disk_attachment" "vm01dd02att" {
  managed_disk_id    = azurerm_managed_disk.vm01dd02.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm01.id
  lun                = "1"
  caching            = "ReadWrite"
  #write_accelerator_enabled = "true"
  depends_on = [
    azurerm_linux_virtual_machine.vm01,azurerm_managed_disk.vm01dd02
  ]
}
#vm01 creation Ended - akkuterravm

