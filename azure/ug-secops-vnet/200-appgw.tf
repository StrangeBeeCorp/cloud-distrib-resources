# Create Static IP for the appgw
resource "azurerm_public_ip" "secops-appgw-public-ip" {
  name                = var.secops-appgw-public-ip-name
  resource_group_name = var.secops-resource-group-name
  location            = var.secops-location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags = {
    Name= "secops-appgw-public-ip"
  }

}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name_thehive = "secops-thehive-backend-pool"
  backend_address_pool_name_cortex  = "secops-cortex-backend-pool"
  http_setting_name_thehive         = "secops-http-thehive"
  http_setting_name_cortex          = "secops-http-cortex"
  listener_name_thehive             = "secops-thehive-listener"
  request_routing_rule_name_thehive = "secops-thehive-rule"
  frontend_port_name                = "secops-appgw-port"
  frontend_ip_configuration_name    = "secops-appgw-public-ip"
  thehive_ssl_certificate_name      = "secops-thehive-certificate"
}

# Create the application gateway
resource "azurerm_application_gateway" "secops-appgw" {
  name                = "secops-appgw"
  resource_group_name = var.secops-resource-group-name
  location            = var.secops-location 
  
  lifecycle {
    create_before_destroy = true
  }
  
  # Specify the appgw service type
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }

  # autoscaling min/max
  autoscale_configuration {
  min_capacity = 0
  max_capacity = 10 
  }

  # Specify the subnet for the appgw
  gateway_ip_configuration {
    name      = "secops-appgw-ip-configuration"
    subnet_id = azurerm_subnet.secops-appgw-frontend-public-subnet.id
  }

  # Specify the frontend port number for the appgw
  frontend_port {
    name  = local.frontend_port_name
    port  = 443
  }
  
  # Specify the public ip address for the appgw
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.secops-appgw-public-ip.id
  }
  
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"

    # If you prefer a custom policy (ensure min_protocol_version is TLSv1_2):
    # policy_type          = "Custom"
    # min_protocol_version = "TLSv1_2"
    # cipher_suites        = [
    #   "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    #   "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    #   # ... add other desired TLS 1.2+ ciphers
    # ]

  }

  # Create thehive backend address pool
  backend_address_pool {
    name           = local.backend_address_pool_name_thehive
  }

  # Create cortex backend address pool
   backend_address_pool {
    name           = local.backend_address_pool_name_cortex
  }

  # Create TheHive probe
  probe {
    name = "thehive_probe"
    protocol = "Http"
    host = "127.0.0.1"
    path = "/thehive/api/status"
    interval = 30
    timeout = 60
    unhealthy_threshold = 5
    port = 9000
  }

  # Create Cortex probe
  probe {
    name = "cortex_probe"
    protocol = "Http"
    host = "127.0.0.1"
    path = "/cortex/api/status"
    interval = 30
    timeout = 60
    unhealthy_threshold = 5
    port = 9001
  }

  # Create thehive backend http block 
  backend_http_settings {
    name                  = local.http_setting_name_thehive
    cookie_based_affinity = "Disabled"
    port                  = 9000
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "thehive_probe"
  }
  
  # Create cortex backend http block 
  backend_http_settings {
    name                  = local.http_setting_name_cortex
    cookie_based_affinity = "Disabled"
    port                  = 9001
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "cortex_probe"
  }
  

  # Create thehive listener
  http_listener {
    name                           = local.listener_name_thehive
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    host_name                      = "thehive.${var.secops-dns-zone-name}"
    ssl_certificate_name           = local.thehive_ssl_certificate_name
  }

  # Managed identity block responsible for importing the certificates from key vault
  identity { 
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.secops-certificate-managed-identity.id]
  }

  # Import the ssl certificate for thehive from key vault
  ssl_certificate {
    name= local.thehive_ssl_certificate_name
    key_vault_secret_id = var.thehive_key_vault_certificate_secret_id
  }
  
  # Create TheHive url_path_map
  url_path_map {
    name = "thehive_url_path_map"
    default_backend_address_pool_name = local.backend_address_pool_name_thehive
    default_backend_http_settings_name = local.http_setting_name_thehive

    path_rule {
      name = "thehive_path_rule"
      paths = ["/thehive", "/thehive/*"]
      backend_address_pool_name = local.backend_address_pool_name_thehive
      backend_http_settings_name = local.http_setting_name_thehive
    }

    path_rule {
      name = "cortex_path_rule"
      paths = ["/cortex", "/cortex/*"]
      backend_address_pool_name = local.backend_address_pool_name_cortex
      backend_http_settings_name = local.http_setting_name_cortex
    }
  }

  # Create thehive routing rule block 
  request_routing_rule {
    name                       = local.request_routing_rule_name_thehive
    rule_type                  = "PathBasedRouting"
    priority                   = 100 
    http_listener_name         = local.listener_name_thehive
    url_path_map_name          = "thehive_url_path_map"
  }

  tags = {
    Name= "secops-appgw"
  }

  depends_on = [
   azurerm_key_vault_access_policy.secops-certificate-managed-identity-key-vault-access-policy,
   azurerm_public_ip.secops-appgw-public-ip
  ]
}

# Create TheHive DNS record, Type "A",  in the public zone (thehive.mydomain.com)
resource "azurerm_dns_a_record" "secops-dns-record-appgw-thehive" {
  name                = "thehive"
  zone_name           = var.secops-dns-zone-name
  resource_group_name  = var.secops-dns-resource-group-name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.secops-appgw-public-ip.id
  tags = {
    Name= "secops-dns-record-appgw-thehive"
  }

}
