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
      // External IP
    }
  }
}
