locals {
  vmss_frontend_config_name = "VMSSIPConfiguration"
  vmss_network_profile_name = "TFENetworkProfile"

  # Update LB settings based on Azure LB or Azure App Gateway
  load_balancer_backend_address_pool_ids       = var.lb.type == "ALB" ? [var.lb.backend_address_pool_id] : []
  application_gateway_backend_address_pool_ids = var.lb.type == "AAG" ? [var.lb.backend_address_pool_id] : []
}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = format("%s-vmss", var.namespace)
  overprovision       = false
  instances           = 1
  sku                 = var.vm_sku
  admin_username      = var.vm_user.username

  # TODO: Figure out auto self healing in azure...
  upgrade_mode = "Manual"
  # upgrade_mode = "Automatic"
  # health_probe_id = var.lb.health_probe_id
  # automatic_os_upgrade_policy {
  #   disable_automatic_rollback  = false
  #   enable_automatic_os_upgrade = false
  # }
  # rolling_upgrade_policy {
  #   max_batch_instance_percent              = 100
  #   max_unhealthy_instance_percent          = 100
  #   max_unhealthy_upgraded_instance_percent = 100
  #   pause_time_between_batches              = "PT10M"
  # }

  zone_balance = length(var.zones) > 0
  zones        = var.zones

  source_image_reference {
    publisher = var.tfe_image.publisher
    offer     = var.tfe_image.offer
    sku       = var.tfe_image.sku
    version   = var.tfe_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 50
  }

  custom_data = base64encode(var.startup_script)
  # Managed Service Identity
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.vm_user.username
    public_key = var.vm_user.public_key
  }

  network_interface {
    name    = local.vmss_network_profile_name
    primary = true

    ip_configuration {
      name      = local.vmss_frontend_config_name
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids       = local.load_balancer_backend_address_pool_ids
      application_gateway_backend_address_pool_ids = local.application_gateway_backend_address_pool_ids
    }
  }

  # Can not be set until after the extension is added to all instances of the VMSS
  # automatic_instance_repair {
  #   enabled = true
  #   # Defaults to 30 mins
  # }

  tags = var.common_tags
}

# https://docs.microsoft.com/bs-latn-ba/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-health-extension
# logs /var/lib/waagent/Microsoft.ManagedServices.ApplicationHealthLinux-1.0.0
resource "azurerm_virtual_machine_scale_set_extension" "main" {
  name                         = format("%s-vmss-health-ext", var.namespace)
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.main.id
  publisher                    = "Microsoft.ManagedServices"
  type                         = "ApplicationHealthLinux"
  auto_upgrade_minor_version   = true
  type_handler_version         = "1.0"
  settings = jsonencode({
    "protocol" : "http",
    "port" : 80,
    "requestPath" : "/_health_check"
  })
}
