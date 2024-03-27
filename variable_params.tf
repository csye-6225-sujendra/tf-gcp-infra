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