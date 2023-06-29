terraform {
  backend "azurerm" {
    resource_group_name  = "practise-project35"
    storage_account_name = "terraform35"
    container_name       = "terraformbackend"
    key                  = "terraformbackend"
  }
}
