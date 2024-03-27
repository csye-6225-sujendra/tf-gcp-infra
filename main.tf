terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_identifier
  region  = var.geographical_region
  zone    = var.geographical_region
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

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}

resource "google_compute_firewall" "deny_ssh" {
  count   = length(var.vpcs)
  name    = "deny-ssh-${count.index}"
  network = google_compute_network.vpc_network[count.index].name

  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["deny-ssh"]
}

resource "google_compute_instance" "vm_instance" {
  name         = var.vm_name
  zone         = var.vm_zone
  machine_type = var.vm_machine_type

  boot_disk {
    initialize_params {
      image = var.vm_image
      type  = var.vm_disk_type
      size  = var.vm_disk_size_gb
    }
  }

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

  tags = ["allow-http", "allow-ssh"]
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



  depends_on = [
    google_sql_database_instance.instance,
    google_compute_subnetwork.webapp[0],
    google_compute_global_address.private_ip_allocation
  ]

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
  rrdatas      = [google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip]
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
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

resource "google_pubsub_topic" "verify_email" {
  name                       = var.google_pubsub_topic_name
  message_retention_duration = "604800s"
  depends_on                 = [google_service_networking_connection.private_services_connection]
}


# Create Pub/Sub subscription
resource "google_pubsub_subscription" "my_subscription" {
  name                 = var.google_pubsub_subscription_name
  topic                = google_pubsub_topic.verify_email.name
  ack_deadline_seconds = 10
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
  name     = "function_email_track"
  location = var.region
}

resource "google_storage_bucket_object" "function_code_objects" {
  name   = "serverless"
  bucket = google_storage_bucket.function_code_bucket.name
  source = "function-source.zip"
}

resource "google_cloudfunctions2_function" "email_verification_function" {

  name     = "send_track_email"
  location = var.region

  build_config {
    runtime     = "nodejs18"
    entry_point = "sendEmail" # Set the entry point

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
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60

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

    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.function_service_account.email
    vpc_connector                  = google_vpc_access_connector.vpc_connector.id

  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  depends_on = [google_pubsub_topic.verify_email, google_storage_bucket_object.function_code_objects]
}


resource "google_vpc_access_connector" "vpc_connector" {
  name          = "my-vpc-connector"
  region        = var.geographical_region
  network       = google_compute_network.vpc_network[0].name
  ip_cidr_range = "10.8.0.0/28"
}


resource "google_project_iam_binding" "pubsub_service_account_roles" {
  project = var.project_identifier
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:service-${var.project_identifier}@gcp-sa-pubsub.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_member" "function_cloudsql_client" {
  project = var.project_identifier
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}
