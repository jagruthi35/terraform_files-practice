
resource "azurerm_resource_group" "practise-project35" {
  name     = "practise-project35"
  location = "eastus2" 
}

resource "azurerm_virtual_network" "practisenetwork35" {
  name                = "practisenetwork35"
  resource_group_name = azurerm_resource_group.practise-project35.name
  location            = azurerm_resource_group.practise-project35.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet1" {
  name                  = "subnet1"
  resource_group_name   = azurerm_resource_group.practise-project35.name
  virtual_network_name  = azurerm_virtual_network.practisenetwork35.name
  address_prefixes      = ["10.0.0.0/25"]
}

resource "azurerm_network_security_group" "practise35-nsg" {
  name                = "practise35-nsg"
  resource_group_name = azurerm_resource_group.practise-project35.name
  location            = azurerm_resource_group.practise-project35.location
}

resource "azurerm_network_security_rule" "inbound_rules" {
  count                     = length(var.inbound_rules)
  name                      = var.inbound_rules[count.index].name
  priority                  = var.inbound_rules[count.index].priority
  direction                 = var.inbound_rules[count.index].direction
  access                    = var.inbound_rules[count.index].access
  protocol                  = var.inbound_rules[count.index].protocol
  source_port_range         = var.inbound_rules[count.index].source_port_range
  destination_port_range    = var.inbound_rules[count.index].destination_port_range
  source_address_prefix     = var.inbound_rules[count.index].source_address_prefix
  destination_address_prefix = var.inbound_rules[count.index].destination_address_prefix
  resource_group_name       = azurerm_resource_group.practise-project35.name
  network_security_group_name = azurerm_network_security_group.practise35-nsg.name
}


resource "azurerm_linux_virtual_machine_scale_set" "ewit35" {
  name                = "ewit35"
  resource_group_name = azurerm_resource_group.practise-project35.name
  location            = azurerm_resource_group.practise-project35.location
  sku                 = "Standard_B2s"
  instances           = 2
  admin_username      = "azureuser"
  admin_password      = "Admin1"
  disable_password_authentication = false
  single_placement_group = true
  upgrade_mode = "Automatic"
  

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  network_interface {
    name                 = "practisenetwork35-nic01"
    primary              = true
    network_security_group_id = azurerm_network_security_group.practise35-nsg.id

    ip_configuration {
      name      = "default"
      subnet_id = azurerm_subnet.subnet1.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "ewitex" {
  name                         = "ewitex"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.ewit35.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
    "fileUris": ["https://sore1.blob.core.windows.net/new1/custom_script2.sh"],
    "commandToExecute": "sh custom_script2.sh"
  })
  timeouts {
    create = "2h"  
  }
}
    
  resource "azurerm_monitor_autoscale_setting" "ewit35autoscale" {
    name                = "ewit35autoscale"
    resource_group_name = azurerm_resource_group.practise-project35.name
    location            = azurerm_resource_group.practise-project35.location
    target_resource_id  = azurerm_linux_virtual_machine_scale_set.ewit35.id

    profile {
      name = "ewit35autoscale"

      capacity {
        default = 2
        minimum = 2
        maximum = 5
      }
    
      rule {
        metric_trigger {
          metric_name        = "Percentage CPU"
          metric_namespace  = "microsoft.compute/virtualmachinescalesets"
          metric_resource_id = azurerm_linux_virtual_machine_scale_set.ewit35.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 75
        }

        scale_action {
          cooldown    = "PT5M"
          direction   = "Increase"
          type        = "ChangeCount"
          value       = "1"
        }
      }
      rule {
        metric_trigger {
          metric_name        = "Percentage CPU"
          metric_resource_id = azurerm_linux_virtual_machine_scale_set.ewit35.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 25
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT1M"
       }
     }
    }
  }
     

resource "azurerm_public_ip" "loadb35-publicip" {
  name                = "loadb35-publicip"
  location            = azurerm_resource_group.practise-project35.location
  resource_group_name = azurerm_resource_group.practise-project35.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "loadb35" {
  name                = "loadb35"
  location            = azurerm_resource_group.practise-project35.location
  resource_group_name = azurerm_resource_group.practise-project35.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "ll35-frontendconfig01"
    public_ip_address_id = azurerm_public_ip.loadb35-publicip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  name                = "bepool"
  loadbalancer_id     = azurerm_lb.loadb35.id
}


resource "azurerm_lb_rule" "loadb35-lbrule01" {
  name                           = "loadb35-lbrule01"
  loadbalancer_id                = azurerm_lb.loadb35.id
  frontend_ip_configuration_name = azurerm_lb.loadb35.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8000
  disable_outbound_snat          = true
}

resource "azurerm_lb_probe" "lb35probe" {
  loadbalancer_id = azurerm_lb.loadb35.id
  name            = "http"
  port            = 80
}

resource "azurerm_lb_outbound_rule" "OutboundRule" {
  name                     = "OutboundRule"
  loadbalancer_id          = azurerm_lb.loadb35.id
  protocol                 = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
  allocated_outbound_ports = 0 

  frontend_ip_configuration {
    name = "ll35-frontendconfig01"
  }
}




