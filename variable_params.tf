variable "project_identifier" {
  description = "project id"
  type        = string
}

variable "geographical_region" {
  description = "GCP region"
  type        = string
}

variable "availability_zone" {
  description = "GCP zone"
  type        = string
}

variable "vpcs" {
  description = "VPC configurations"
  type = list(object({
    name                  = string
    vpc                   = string
    websubnet             = string
    dbsubnet              = string
    webapp_cidr           = string
    db_cidr               = string
    webapproute           = string
    privateipgoogleaccess = bool
  }))
}
variable "webapp_subnetroute_cidr" {
  description = "CIDR for the webapp subnet route"
  type        = string
}

variable "auto_subnet_creation" {
  description = "Auto create subnets"
  type        = bool
}

variable "remove_default_routes" {
  description = "Remove default routes"
  type        = bool
}

variable "routing_mode" {
  description = "Routing mode"
  type        = string
}

variable "next_hop_gateway" {
  description = "Next hop gateway"
  type        = string
}

variable "vm_name" {
  description = "The name of the VM instance"
  type        = string
}

variable "vm_zone" {
  description = "The zone for the VM instance"
  type        = string
}

variable "vm_machine_type" {
  description = "The machine type for the VM instance"
  type        = string
}

variable "vm_image" {
  description = "The custom image for the VM boot disk"
  type        = string
}

variable "vm_disk_type" {
  description = "The disk type for the VM boot disk"
  type        = string
}

variable "vm_disk_size_gb" {
  description = "The size of the VM boot disk in GB"
  type        = number
}

variable "app_port" {
  description = "The application port"
  type        = string
}

variable "cloudsql_database_name" {
  description = "Name of the Cloud SQL database"
  type        = string
}

variable "cloudsql_database_user_name" {
  description = "Name of the Cloud SQL database user"
  type        = string
}

variable "cloudsql_password_length" {
  description = "Length of the randomly generated password for the Cloud SQL user"
  type        = number
}

variable "cloudsql_password_special" {
  description = "Whether to include special characters in the Cloud SQL user password"
  type        = bool
}

variable "cloudsql_password_override_special" {
  description = "Override default special characters for the Cloud SQL user password"
  type        = string
}

variable "cloud_sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "region" {
  description = "Region for the Cloud SQL instance"
  type        = string
}

variable "google_sql_deletion_policy" {
  description = "Deletion policy for Google Cloud SQL resources"
  type        = string
}

variable "cloud_sql_instance_tier" {
  description = "Tier for the Cloud SQL instance"
  type        = string
}

variable "cloud_sql_instance_ipv4_enabled" {
  description = "Whether IPv4 is enabled for the Cloud SQL instance"
  type        = bool
}

variable "cloud_sql_instance_availability_type" {
  description = "Availability type for the Cloud SQL instance"
  type        = string
}

variable "cloud_sql_instance_disk_type" {
  description = "Disk type for the Cloud SQL instance"
  type        = string
}

variable "cloud_sql_instance_disk_size" {
  description = "Size of the disk for the Cloud SQL instance (in GB)"
  type        = number
}

variable "cloud_sql_instance_deletion_protection" {
  description = "Whether deletion protection is enabled for the Cloud SQL instance"
  type        = bool
}

variable "ssl_cert_common_name" {
  description = "Common name for SSL certificate"
  type        = string
}

variable "db_port" {
  description = "The port used by the database"
  type        = string
}

variable "db_dialect" {
  description = "The dialect used by the database"
  type        = string
}

variable "db_pool_max" {
  description = "The maximum number of connections in the database pool"
  type        = number
}

variable "db_pool_min" {
  description = "The minimum number of connections in the database pool"
  type        = number
}

variable "db_pool_acquire" {
  description = "The maximum time to acquire a connection in milliseconds for the database pool"
  type        = number
}

variable "db_pool_idle" {
  description = "The maximum idle time for a connection in milliseconds in the database pool"
  type        = number
}

variable "cloud_sql_version" {
  description = "Cloud SQL version"
  type        = string
}

variable "address_name" {
  description = "Name of the global address"
  type        = string
}

variable "address_type" {
  description = "Type of the address"
  type        = string
}

variable "address_purpose" {
  description = "Purpose of the address"
  type        = string
}

variable "address_prefix_length" {
  description = "Prefix length of the address"
  type        = number
}

variable "service_name" {
  description = "service name"
  type        = string
}

variable "service_account_url" {
  description = "gcp auth url"
  type        = string
}

variable "dns_record_name" {
  description = "Name for the DNS record"
  type        = string
}

variable "dns_record_type" {
  description = "Type for the DNS record"
  type        = string
}

variable "dns_recordset_ttl" {
  description = "TTL for the DNS recordset"
  type        = number
}

variable "dns_recordset_managed_zone" {
  description = "Managed zone for the DNS recordset"
  type        = string
}

variable "google_service_account_name" {
  description = "Name for the Google service account"
  type        = string
}

variable "google_service_account_display" {
  description = "Display name for the Google service account"
  type        = string
}

variable "gcp_iam_binding_role_logging" {
  description = "Role for logging IAM binding"
  type        = string
}

variable "gcp_iam_binding_role_monitoring" {
  description = "Role for monitoring IAM binding"
  type        = string
}

variable "google_pubsub_topic_name" {
  description = "pub sub topic name"
  type        = string
}

variable "google_pubsub_subscription_name" {
  description = "pub sub subscription name"
  type        = string
}

variable "google_function_service_account_name" {
  description = "function service account name"
  type        = string
}

variable "google_function_service_account_display" {
  description = "function service account display name"
  type        = string
}

variable "google_project_iam_binding_role_TokenCreator" {
  description = "iam binding roles"
  type        = string
}

variable "google_project_iam_member_function_cloudsql_client_role" {
  description = "iam binding roles for function sql client"
  type        = string
}

variable "google_project_iam_binding_pubsub_service_account_role" {
  description = "iam binding roles for pub sub service account"
  type        = string
}


variable "google_vpc_access_connector_name" {
  description = "google vpc access connector name"
  type        = string
}


variable "google_vpc_access_connector_ip_cidr_range" {
  description = "google vpc access connector ip cidr range"
  type        = string
}

variable "google_storage_bucket_name" {
  type        = string
  description = "Name of the Google Cloud Storage bucket where function source code and related objects are stored."
  default     = "function_email_track"
}

variable "google_storage_bucket_object_name" {
  type        = string
  description = "Name of the object within the Google Cloud Storage bucket."
  default     = "serverless"
}

variable "google_storage_bucket_object_source" {
  type        = string
  description = "Path to the source code ZIP file for the function."
  default     = "function-source.zip"
}

variable "google_cloudfunctions2_function_name" {
  type        = string
  description = "Name of the Google Cloud Function."
  default     = "send_track_email"
}

variable "google_cloudfunctions2_function_build_config_runtime" {
  type        = string
  description = "Runtime environment for the function."
  default     = "nodejs18"
}

variable "google_cloudfunctions2_function_build_config_entry_point" {
  type        = string
  description = "Entry point for the function code."
  default     = "sendEmail"
}

variable "google_cloudfunctions2_function_service_config_max_instance_count" {
  type        = number
  description = "Maximum number of instances for the function."
  default     = 3
}

variable "google_cloudfunctions2_function_service_config_min_instance_count" {
  type        = number
  description = "Minimum number of instances for the function."
  default     = 1
}

variable "google_cloudfunctions2_function_service_config_timeout_seconds" {
  type        = number
  description = "Maximum execution time allowed for the function, in seconds."
  default     = 60
}

variable "google_cloudfunctions2_function_service_config_available_memory" {
  type        = string
  description = "Amount of memory available to the function instance."
  default     = "256M"
}

variable "google_cloudfunctions2_function_service_config_ingress_settings" {
  type        = string
  description = "Network ingress settings for the function."
  default     = "ALLOW_INTERNAL_ONLY"
}

variable "google_cloudfunctions2_function_event_trigger_event_type" {
  type        = string
  description = "Type of event that triggers the function."
  default     = "google.cloud.pubsub.topic.v1.messagePublished"
}

variable "google_cloudfunctions2_function_event_trigger_retry_policy" {
  type        = string
  description = "Retry policy for failed function invocations."
  default     = "RETRY_POLICY_RETRY"
}

variable "Autoscaler_service_account_name" {
  type        = string
  description = "Autoscaler service account name"
}

variable "Autoscaler_service_account_display_name" {
  type        = string
  description = "Autoscaler service account display name"
}

variable "google_compute_region_instance_template_name_prefix" {
  type    = string
  default = "webapp-template-"
}

variable "google_compute_region_instance_template_description" {
  type    = string
  default = "Creating Regional Compute Instance Template"
}

variable "google_compute_region_instance_template_auto_delete" {
  type    = bool
  default = true
}

variable "google_compute_region_instance_template_boot" {
  type    = bool
  default = true
}

variable "google_compute_region_instance_template_can_ip_forward" {
  type    = bool
  default = false
}

variable "google_project_iam_binding_pubsub_publisher_role" {
  type    = string
  default = "roles/pubsub.publisher"
}

variable "google_pubsub_topic_verify_email_message_retention_duration" {
  type    = string
  default = "604800s"
}

variable "google_pubsub_subscription_ack_deadline_seconds" {
  type    = number
  default = 10
}

variable "google_compute_http_health_check_name" {
  type    = string
  default = "webapp-health-check"
}

variable "google_compute_http_health_request_path" {
  type    = string
  default = "/healthz"
}

variable "google_compute_http_health_port" {
  type    = number
  default = 8080
}

variable "google_compute_region_autoscaler_name" {
  type    = string
  default = "webapp-autoscaler"
}

variable "google_compute_region_autoscaler_max_replicas" {
  type    = number
  default = 6
}

variable "google_compute_region_autoscaler_min_replicas" {
  type    = number
  default = 3
}

variable "google_compute_region_autoscaler_cpu_utilization_target" {
  type    = number
  default = 0.05
}

variable "google_project_iam_binding_compute_instance_role" {
  type    = string
  default = "roles/compute.instanceAdmin.v1"
}

variable "google_compute_region_instance_group_manager_name" {
  type    = string
  default = "webapp-igm"
}

variable "google_compute_region_instance_group_manager_base_instance_name" {
  type    = string
  default = "webapp"
}

variable "google_compute_region_instance_group_manager_port" {
  type    = number
  default = 8080
}

variable "google_compute_global_forwarding_rule_name" {
  type    = string
  default = "https-forwarding-rule"
}

variable "google_compute_global_forwarding_rule_load_balancing_scheme" {
  type    = string
  default = "EXTERNAL"
}

variable "google_compute_global_forwarding_rule_port_range" {
  type    = string
  default = "443"
}

variable "google_dns_managed_zone_existing_zone_name" {
  type    = string
  default = "sujendragharat"
}

variable "google_compute_backend_service_name" {
  type    = string
  default = "webapp-backend"
}

variable "google_compute_backend_service_protocol" {
  type    = string
  default = "HTTP"
}

variable "google_compute_backend_service_load_balancing_scheme" {
  type    = string
  default = "EXTERNAL"
}

variable "google_compute_backend_service_timeout_sec" {
  type    = number
  default = 10
}

variable "google_kms_key_ring_name" {
  type    = string
  default = "rings-of-kms-3"
}

variable "google_kms_crypto_key_name" {
  type    = string
  default = "vm-crypto-key"
}

variable "google_kms_crypto_key_rotation_period" {
  type    = string
  default = "2592000s" # Assuming this represents a rotation period in seconds
}

variable "google_kms_crypto_key_iam_binding_role" {
  type    = string
  default = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

variable "google_kms_crypto_key_iam_binding_service_account" {
  type    = string
  default = "service-279360147711@compute-system.iam.gserviceaccount.com"
}

variable "google_kms_crypto_key_gcp_sa_cloud_sql_service" {
  type    = string
  default = "gcp_sa_cloud_sql"
}

variable "google_kms_crypto_key_iam_binding_crypto_key_role" {
  type    = string
  default = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

variable "google_kms_crypto_key_storage_crypto_key_name" {
  type    = string
  default = "storage-crypto-key"
}

variable "google_kms_crypto_key_storage_crypto_key_rotation_period" {
  type    = string
  default = "2592000s" # Assuming this represents a rotation period in seconds
}

variable "google_compute_firewall_name" {
  type    = string
  default = "allow-lb-firewall"
}

variable "google_compute_firewall_default" {
  type    = string
  default = "l7-xlb-fw-allow-hc"
}

variable "google_compute_url_map_default_name" {
  type    = string
  default = "l7-xlb-url-map"
}

variable "google_compute_managed_ssl_certificate_webapp_ssl_cert" {
  type    = string
  default = "webapp-ssl-cert"
}

variable "google_compute_target_https_proxy_https_proxy_name" {
  type    = string
  default = "l7-xlb-target-http-proxy"
}

variable "mailgun_api_key" {
  type = string
  # No default value provided to ensure that sensitive data is not exposed
}