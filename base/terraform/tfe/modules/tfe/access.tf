locals {
  msi_foreach = toset(var.keyvault.enabled ? ["msi"] : [])
}

data "azurerm_client_config" "current" {}

# Grant the MSI access to the Azure Key Vault
resource "azurerm_role_assignment" "msi" {
  for_each             = local.msi_foreach
  principal_id         = azurerm_linux_virtual_machine_scale_set.main.identity[0].principal_id
  role_definition_name = "Reader"
  scope                = var.keyvault.id
}

# Add keyvault policy so that the MSI can read the secrets
resource "azurerm_key_vault_access_policy" "msi" {
  for_each     = local.msi_foreach
  key_vault_id = var.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine_scale_set.main.identity[0].principal_id

  secret_permissions = [
    "get",
  ]
}
