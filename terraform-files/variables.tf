

variable "inbound_rules" {
  type = list(object({
    name                   = string
    priority               = number
    direction              = string
    access                 = string
    protocol               = string
    source_port_range      = string
    destination_port_range = string
    source_address_prefix  = string
    destination_address_prefix = string
  }))
  
  default = [
    {
      name                   = "allow-http-inbound"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "80"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    },

    {
      name                   = "allow-ssh-inbound"
      priority               = 200
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "22"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    },

    {
      name                   = "allow-guni-inbound"
      priority               = 210
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "8000"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    },

    {
      name                   = "allow-py-inbound"
      priority               = 220
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "5000"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    },

    {
      name                   = "allow-sql-inbound"
      priority               = 230
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "1433"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    }
  ]
}



