# Import the key vault resource 
data "azurerm_key_vault" "secops-key-vault" {
  name                 = var.secops-key-vault-name
  resource_group_name  = var.secops-resource-group-name
}

# Create the managed-identity used by the appgw to get certificates stored in key vault
resource "azurerm_user_assigned_identity" "secops-certificate-managed-identity" {
  name = "secops-certificate-managed-identity"
  location            = var.secops-location 
  resource_group_name  = var.secops-resource-group-name
  tags = {
    Name= "secops-certificate-managed-identity"
  }
}

# The only required permission for the managed-identity in key vault access policy is get on secrets
resource "azurerm_key_vault_access_policy" "secops-certificate-managed-identity-key-vault-access-policy" {
  key_vault_id = data.azurerm_key_vault.secops-key-vault.id
  tenant_id = data.azurerm_key_vault.secops-key-vault.tenant_id
  object_id = azurerm_user_assigned_identity.secops-certificate-managed-identity.principal_id 

  secret_permissions = [
    "get",
  ]
}
