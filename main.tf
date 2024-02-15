terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpcnetwork" {
  name                            = var.vpc_name
  auto_create_subnetworks         = var.auto_create_subnets
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes
}

resource "google_compute_subnetwork" "webapp" {
  name                     = var.web_subnet_name
  ip_cidr_range            = var.web_app_cidr
  network                  = google_compute_network.vpcnetwork.self_link
  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_subnetwork" "db" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_cidr
  network                  = google_compute_network.vpcnetwork.self_link
  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_route" "webapp_route" {
  name             = var.web_app_route_name
  network          = google_compute_network.vpcnetwork.name
  dest_range       = var.web_app_route_cidr
  priority         = 1000
  next_hop_gateway = var.next_hop_gateway
}