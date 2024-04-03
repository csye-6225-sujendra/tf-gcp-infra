# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "4.51.0"
#     }
#   }
# }

provider "google" {
  project = var.project_identifier
  region  = var.geographical_region
  zone    = var.availability_zone
}
resource "google_compute_network" "vpc_network" {
  count                           = length(var.vpcs)
  name                            = var.vpcs[count.index].vpc
  auto_create_subnetworks         = var.auto_subnet_creation
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.remove_default_routes
}

resource "google_compute_subnetwork" "webapp" {
  count                    = length(var.vpcs)
  name                     = var.vpcs[count.index].websubnet
  ip_cidr_range            = var.vpcs[count.index].webapp_cidr
  region                   = var.geographical_region
  network                  = google_compute_network.vpc_network[count.index].self_link
  private_ip_google_access = var.vpcs[count.index].privateipgoogleaccess
}
resource "google_compute_subnetwork" "db" {
  count                    = length(var.vpcs)
  name                     = var.vpcs[count.index].dbsubnet
  ip_cidr_range            = var.vpcs[count.index].db_cidr
  region                   = var.geographical_region
  network                  = google_compute_network.vpc_network[count.index].self_link
  private_ip_google_access = var.vpcs[count.index].privateipgoogleaccess
}

resource "google_compute_route" "webapp_route" {
  count            = length(var.vpcs)
  name             = var.vpcs[count.index].webapproute
  network          = google_compute_network.vpc_network[count.index].self_link
  dest_range       = var.webapp_subnetroute_cidr
  priority         = 1000
  next_hop_gateway = var.next_hop_gateway
}


resource "google_compute_firewall" "allow_application" {
  count   = length(var.vpcs)
  name    = "allow-application${count.index}"
  network = google_compute_network.vpc_network[count.index].name

  allow {
    protocol = "tcp"
    ports    = [var.app_port]
  }

  source_ranges = [google_compute_global_address.lb_ipv4_address.address]
  target_tags   = ["allow-http"]
}

# resource "google_compute_firewall" "deny_ssh" {
#   count   = length(var.vpcs)
#   name    = "deny-ssh-${count.index}"
#   network = google_compute_network.vpc_network[count.index].name

#   deny {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["deny-ssh"]

# }


# resource "google_compute_instance" "vm_instance" {
#   name         = var.vm_name
#   zone         = var.vm_zone
#   machine_type = var.vm_machine_type

#   boot_disk {
#     initialize_params {
#       image = var.vm_image
#       type  = var.vm_disk_type
#       size  = var.vm_disk_size_gb
#     }
#   }

#   network_interface {
#     network    = google_compute_network.vpc_network[0].id
#     subnetwork = google_compute_subnetwork.webapp[0].id

#     access_config {
#       // Ephemeral public IP
#     }
#   }

#   service_account {
#     email  = google_service_account.vm_service_account.email
#     scopes = [var.service_account_url]
#   }

#   tags = ["allow-http", "allow-ssh"]
#   metadata_startup_script = templatefile("startup.sh", {
#     db_host         = google_sql_database_instance.instance.private_ip_address,
#     db_user         = google_sql_user.user.name,
#     db_password     = random_password.cloudsql_password.result,
#     db_name         = google_sql_database.database.name,
#     db_port         = var.db_port,
#     db_dialect      = var.db_dialect,
#     db_pool_max     = var.db_pool_max,
#     db_pool_min     = var.db_pool_min,
#     db_pool_acquire = var.db_pool_acquire,
#     db_pool_idle    = var.db_pool_idle
#   })



#   depends_on = [
#     google_sql_database_instance.instance,
#     google_compute_subnetwork.webapp[0],
#     google_compute_global_address.private_ip_allocation
#   ]

# }

# Regional Compute Instance Template
resource "google_compute_region_instance_template" "webapp_template" {
  name_prefix  = var.google_compute_region_instance_template_name_prefix
  description  = var.google_compute_region_instance_template_description
  machine_type = var.vm_machine_type
  region       = var.geographical_region

  disk {
    source_image = var.vm_image
    auto_delete  = var.google_compute_region_instance_template_auto_delete
    boot         = var.google_compute_region_instance_template_boot
    disk_size_gb = var.vm_disk_size_gb
    disk_type    = var.vm_disk_type
  }

  can_ip_forward = var.google_compute_region_instance_template_can_ip_forward

  network_interface {
    network    = google_compute_network.vpc_network[0].id
    subnetwork = google_compute_subnetwork.webapp[0].id
    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = [var.service_account_url]
  }

  tags = ["allow-http", "allow-ssh", "allow-health-check", "deny-ssh"]

  metadata_startup_script = templatefile("startup.sh", {
    db_host         = google_sql_database_instance.instance.private_ip_address,
    db_user         = google_sql_user.user.name,
    db_password     = random_password.cloudsql_password.result,
    db_name         = google_sql_database.database.name,
    db_port         = var.db_port,
    db_dialect      = var.db_dialect,
    db_pool_max     = var.db_pool_max,
    db_pool_min     = var.db_pool_min,
    db_pool_acquire = var.db_pool_acquire,
    db_pool_idle    = var.db_pool_idle
  })
}


resource "google_compute_global_address" "private_ip_allocation" {
  name          = var.address_name
  address_type  = var.address_type
  purpose       = var.address_purpose
  prefix_length = var.address_prefix_length
  network       = google_compute_network.vpc_network[0].self_link
}

resource "google_service_networking_connection" "private_services_connection" {
  network                 = google_compute_network.vpc_network[0].self_link
  service                 = var.service_name
  reserved_peering_ranges = [google_compute_global_address.private_ip_allocation.name]
}

resource "google_sql_database_instance" "instance" {
  name             = var.cloud_sql_instance_name
  region           = var.region
  database_version = var.cloud_sql_version
  depends_on       = [google_service_networking_connection.private_services_connection]

  settings {
    tier = var.cloud_sql_instance_tier

    ip_configuration {
      ipv4_enabled    = var.cloud_sql_instance_ipv4_enabled
      private_network = google_compute_network.vpc_network[0].self_link
    }

    availability_type = var.cloud_sql_instance_availability_type
    disk_type         = var.cloud_sql_instance_disk_type
    disk_size         = var.cloud_sql_instance_disk_size

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

    // Other settings...
  }

  deletion_protection = var.cloud_sql_instance_deletion_protection
}

resource "google_sql_database" "database" {
  name            = var.cloudsql_database_name
  instance        = google_sql_database_instance.instance.name
  deletion_policy = var.google_sql_deletion_policy
}

resource "google_sql_user" "user" {
  name            = var.cloudsql_database_user_name
  instance        = google_sql_database_instance.instance.name
  password        = random_password.cloudsql_password.result
  deletion_policy = var.google_sql_deletion_policy
}

resource "random_password" "cloudsql_password" {
  length           = var.cloudsql_password_length
  special          = var.cloudsql_password_special
  override_special = var.cloudsql_password_override_special
}

resource "google_dns_record_set" "a_record" {
  name         = var.dns_record_name
  type         = var.dns_record_type
  ttl          = var.dns_recordset_ttl
  managed_zone = var.dns_recordset_managed_zone
  rrdatas      = [google_compute_global_address.lb_ipv4_address.address]
}

resource "google_service_account" "vm_service_account" {
  account_id   = var.google_service_account_name
  display_name = var.google_service_account_display
}

resource "google_project_iam_binding" "logging_admin_binding" {
  project = var.project_identifier
  role    = var.gcp_iam_binding_role_logging

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "google_project_iam_binding" "monitoring_metric_writer_binding" {
  project = var.project_identifier
  role    = var.gcp_iam_binding_role_monitoring

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project_identifier
  role    = var.google_project_iam_binding_pubsub_publisher_role

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

resource "google_pubsub_topic" "verify_email" {
  name                       = var.google_pubsub_topic_name
  message_retention_duration = var.google_pubsub_topic_verify_email_message_retention_duration
  depends_on                 = [google_service_networking_connection.private_services_connection]
}


# Create Pub/Sub subscription
resource "google_pubsub_subscription" "my_subscription" {
  name                 = var.google_pubsub_subscription_name
  topic                = google_pubsub_topic.verify_email.name
  ack_deadline_seconds = var.google_pubsub_subscription_ack_deadline_seconds
  expiration_policy {
    ttl = "604800s"
  }
}

# Create a service account for Cloud Functions
resource "google_service_account" "function_service_account" {
  account_id   = var.google_function_service_account_name
  display_name = var.google_function_service_account_display
}

# Create IAM roles and bindings for the service account
resource "google_project_iam_binding" "function_service_account_roles" {
  project = var.project_identifier
  role    = var.google_project_iam_binding_role_TokenCreator

  members = [
    "serviceAccount:${google_service_account.function_service_account.email}"
  ]
}


resource "google_storage_bucket" "function_code_bucket" {
  name     = var.google_storage_bucket_name
  location = var.region
}

resource "google_storage_bucket_object" "function_code_objects" {
  name   = var.google_storage_bucket_object_name
  bucket = google_storage_bucket.function_code_bucket.name
  source = var.google_storage_bucket_object_source
}

resource "google_cloudfunctions2_function" "email_verification_function" {

  name     = var.google_cloudfunctions2_function_name
  location = var.region

  build_config {
    runtime     = var.google_cloudfunctions2_function_build_config_runtime
    entry_point = var.google_cloudfunctions2_function_build_config_entry_point # Set the entry point

    source {
      storage_source {
        bucket = google_storage_bucket.function_code_bucket.name
        object = google_storage_bucket_object.function_code_objects.name
      }
    }

    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
      # DB_HOST           = google_sql_database_instance.instance.private_ip_address,
      # DB_USER           = google_sql_user.user.name,
      # DB_PASSWORD       = random_password.cloudsql_password.result,
      # DB_NAME           = google_sql_database.database.name,
      # DB_PORT           = var.db_port,
      # DB_DIALECT        = var.db_dialect,
      # DB_POOL_MAX       = var.db_pool_max,
      # DB_POOL_MIN       = var.db_pool_min,
      # DB_POOL_ACQUIRE   = var.db_pool_acquire,
      # DB_POOL_IDLE      = var.db_pool_idle
    }
  }

  service_config {
    max_instance_count = var.google_cloudfunctions2_function_service_config_max_instance_count
    min_instance_count = var.google_cloudfunctions2_function_service_config_min_instance_count
    available_memory   = var.google_cloudfunctions2_function_service_config_available_memory
    timeout_seconds    = var.google_cloudfunctions2_function_service_config_timeout_seconds

    environment_variables = {
      PUBSUB_TOPIC        = google_pubsub_topic.verify_email.name
      SERVICE_CONFIG_TEST = "config_test"
      DB_HOST             = google_sql_database_instance.instance.private_ip_address,
      DB_USER             = google_sql_user.user.name,
      DB_PASSWORD         = random_password.cloudsql_password.result,
      DB_NAME             = google_sql_database.database.name,
      DB_PORT             = var.db_port,
      DB_DIALECT          = var.db_dialect,
      DB_POOL_MAX         = var.db_pool_max,
      DB_POOL_MIN         = var.db_pool_min,
      DB_POOL_ACQUIRE     = var.db_pool_acquire,
      DB_POOL_IDLE        = var.db_pool_idle
    }

    ingress_settings               = var.google_cloudfunctions2_function_service_config_ingress_settings
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.function_service_account.email
    vpc_connector                  = google_vpc_access_connector.vpc_connector.id

  }

  event_trigger {
    trigger_region = var.region
    event_type     = var.google_cloudfunctions2_function_event_trigger_event_type
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = var.google_cloudfunctions2_function_event_trigger_retry_policy
  }

  depends_on = [google_pubsub_topic.verify_email, google_storage_bucket_object.function_code_objects]
}


resource "google_vpc_access_connector" "vpc_connector" {
  name          = var.google_vpc_access_connector_name
  region        = var.geographical_region
  network       = google_compute_network.vpc_network[0].name
  ip_cidr_range = var.google_vpc_access_connector_ip_cidr_range
}


resource "google_project_iam_binding" "pubsub_service_account_roles" {
  project = var.project_identifier
  role    = var.google_project_iam_binding_pubsub_service_account_role

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

resource "google_project_iam_member" "function_cloudsql_client" {
  project = var.project_identifier
  role    = var.google_project_iam_member_function_cloudsql_client_role
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}

resource "google_compute_http_health_check" "http_health_check" {
  name                = var.google_compute_http_health_check_name
  check_interval_sec  = 60
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  port                = var.google_compute_http_health_port
  request_path        = var.google_compute_http_health_request_path
}

resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = var.google_compute_region_autoscaler_name
  region = var.region
  target = google_compute_region_instance_group_manager.webapp_igm.self_link
  autoscaling_policy {
    max_replicas    = var.google_compute_region_autoscaler_max_replicas
    min_replicas    = var.google_compute_region_autoscaler_min_replicas
    cooldown_period = 60
    cpu_utilization {
      target = var.google_compute_region_autoscaler_cpu_utilization_target
    }
  }
}

resource "google_project_iam_binding" "instance_admin_binding" {
  project = var.project_identifier
  role    = var.google_project_iam_binding_compute_instance_role

  members = [
    "serviceAccount:${google_service_account.autoscaler_service_account.email}",
  ]
}


resource "google_compute_region_instance_group_manager" "webapp_igm" {
  name               = var.google_compute_region_instance_group_manager_name
  region             = var.geographical_region
  base_instance_name = var.google_compute_region_instance_group_manager_base_instance_name

  version {
    instance_template = google_compute_region_instance_template.webapp_template.id
    name              = "primary"
  }

  named_port {
    name = "http"
    port = var.google_compute_region_instance_group_manager_port
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.http_health_check.self_link
    initial_delay_sec = 300
  }

  target_size = 3
}


# Load Balancer
resource "google_compute_global_address" "lb_ipv4_address" {
  name = "lb-ipv4-address"
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = var.google_compute_global_forwarding_rule_name
  ip_protocol           = "TCP"
  load_balancing_scheme = var.google_compute_global_forwarding_rule_load_balancing_scheme
  ip_address            = google_compute_global_address.lb_ipv4_address.address
  port_range            = var.google_compute_global_forwarding_rule_port_range
  target                = google_compute_target_https_proxy.https_proxy.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "l7-xlb-target-http-proxy"
  provider         = google
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.webapp_ssl_cert.name]
  depends_on = [
    google_compute_managed_ssl_certificate.webapp_ssl_cert
  ]
}

# url map
resource "google_compute_url_map" "default" {
  name            = "l7-xlb-url-map"
  provider        = google
  default_service = google_compute_backend_service.webapp_backend.id
}

resource "google_compute_managed_ssl_certificate" "webapp_ssl_cert" {
  name = "webapp-ssl-cert"

  managed {
    domains = [var.dns_record_name]
  }
}

# resource "google_compute_url_map" "https_url_map" {
#   name            = "https-url-map"
#   default_service = google_compute_backend_service.webapp_backend.self_link
# }


resource "google_compute_backend_service" "webapp_backend" {
  name                            = var.google_compute_backend_service_name
  protocol                        = var.google_compute_backend_service_protocol
  port_name                       = "http"
  health_checks                   = [google_compute_http_health_check.http_health_check.self_link]
  load_balancing_scheme           = var.google_compute_backend_service_load_balancing_scheme
  timeout_sec                     = var.google_compute_backend_service_timeout_sec
  connection_draining_timeout_sec = 300
  enable_cdn                      = true

  backend {
    group           = google_compute_region_instance_group_manager.webapp_igm.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# Firewall Rule
resource "google_compute_firewall" "allow_lb" {
  name    = "allow-lb-firewall"
  network = google_compute_network.vpc_network[0].name

  allow {
    protocol = "tcp"
    ports    = ["443", "8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  source_tags   = ["allow-http", "allow-ssh", "allow-health-check", "deny-ssh"]
}

resource "google_compute_firewall" "default" {
  name          = "l7-xlb-fw-allow-hc"
  provider      = google
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network[0].name
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}
data "google_dns_managed_zone" "existing_zone" {
  name = var.google_dns_managed_zone_existing_zone_name
}

resource "google_service_account" "autoscaler_service_account" {
  account_id   = var.Autoscaler_service_account_name
  display_name = var.Autoscaler_service_account_display_name
}
