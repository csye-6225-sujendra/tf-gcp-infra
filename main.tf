terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}


provider "google" {
  credentials = file(var.credentials_file)
  project = var.project_id
  region  = var.region
  zone    = var.region
}
resource "google_compute_network" "vpc_network" {
  count                           = length(var.vpcs)
  name                            = var.vpcs[count.index].vpc_name
  auto_create_subnetworks         = var.auto_create_subnets
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes
}

resource "google_compute_subnetwork" "webapp" {
  count                    = length(var.vpcs)
  name                     = var.vpcs[count.index].websubnet_name
  ip_cidr_range            = var.vpcs[count.index].webapp_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network[count.index].self_link
  private_ip_google_access = var.vpcs[count.index].privateipgoogleaccess
}
resource "google_compute_subnetwork" "db" {
  count                    = length(var.vpcs)
  name                     = var.vpcs[count.index].dbsubnet_name
  ip_cidr_range            = var.vpcs[count.index].db_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network[count.index].self_link
  private_ip_google_access = var.vpcs[count.index].privateipgoogleaccess
}

resource "google_compute_route" "webapp_route" {
  count            = length(var.vpcs)
  name             = var.vpcs[count.index].websubnetroutename
  network          = google_compute_network.vpc_network[count.index].self_link
  dest_range       = var.web_app_route_cidr
  priority         = 1000
  next_hop_gateway = var.next_hop_gateway
}

resource "google_compute_firewall" "private_vpc_webapp_firewall" {
  name = var.webapp_firewall_name
  network = google_compute_network.vpc_network.self_link
 
  allow {
    protocol = var.webapp_firewall_protocol
    ports = var.webapp_firewall_protocol_allow_ports
  }
 
  source_tags = var.webapp_firewall_source_tags
  target_tags = var.webapp_firewall_target_tags
}
 
resource "google_compute_firewall" "private_vpc_ssh_firewall" {
  name = var.webapp_subnet_ssh
  network = google_compute_network.vpc_network.self_link
 
  deny {
    protocol = var.webapp_firewall_protocol
    ports = var.webapp_firewall__protocol_deny_ports
  }
 
  source_tags = var.webapp_firewall_source_tags
  target_tags = var.webapp_firewall_target_tags
}
 
resource "google_compute_instance" "webapp_instance" {
  name = var.compute_instance_name
  machine_type = var.machine_type
  zone = var.zone
 
  tags = var.compute_instance_tags
 
  boot_disk {
    initialize_params {
      image = var.instance_image
      size = var.instance_size
      type = var.webapp_bootdisk_type
    }
  }
 
  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name
 
    access_config {
      network_tier = var.network_tier
    }
  }
}