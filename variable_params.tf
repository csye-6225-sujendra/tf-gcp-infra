variable "project_id" {
  description = "id for the project"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The GCP zone to deploy resources"
  type        = string
}

variable "credentials_file" {
  description = "File have gcp credentials for seervice account"
  type        = string
}

variable "vpcs" {
  description = "A list of objects representing VPC configurations"
  type = list(object({
    name = string
    # description = "The name of the VPC"
    vpc_name = string
    # description = "The name of web subnet"
    websubnet_name = string
    # description = "The name of db subnet"
    dbsubnet_name = string
    # description = "CIDR for the webapp subnet"
    webapp_subnet_cidr = string
    # description = "CIDR for the db subnet"
    db_subnet_cidr = string
    # description = "CIDR for the webapp subnet route"
    websubnetroutename = string
    # description = "To set private ip google access of subnets to on or off"
    privateipgoogleaccess = bool
  }))
}
variable "web_app_route_cidr" {
  description = "CIDR for the webapp subnet route"
  type        = string
}

variable "auto_create_subnets" {
  description = "To set value to true or false for automatically creating subnets"
  type        = bool
}

variable "delete_default_routes" {
  description = "To set value to true or false to delete default routes"
  type        = bool
}

variable "routing_mode" {
  description = "To set routing mode"
  type        = string
}

variable "next_hop_gateway" {
  description = "To set next hop gateway value"
  type        = string
}

variable "credentials_file" {
  description = "Path to the Google Cloud Platform service account key file"
  type        = string
}


 
variable "webapp_firewall_name" {
  description = "Name of the firewall for the web application"
  type        = string
}
 
variable "webapp_firewall_protocol" {
  description = "Protocol for the web application firewall rule (e.g., tcp, udp)"
  type        = string
}
 
variable "webapp_firewall_protocol_allow_ports" {
  description = "List of ports to allow for the web application firewall rule"
  type        = list(string)
}
 
variable "webapp_firewall_source_tags" {
  description = "Source tags for the web application firewall rule"
  type        = list(string)
}
 
variable "webapp_firewall_target_tags" {
  description = "Target tags for the web application firewall rule"
  type        = list(string)
}
 
variable "webapp_subnet_ssh" {
  description = "Name of the firewall rule for SSH access to the web application subnet"
  type        = string
}
 
variable "webapp_firewall__protocol_deny_ports" {
  description = "List of ports to deny for the web application SSH firewall rule"
  type        = list(string)
}
 
variable "compute_instance_name" {
  description = "Name of the compute instance for the web application"
  type        = string
}
 
variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
}
 
 
variable "instance_image" {
  description = "URL of the image for the compute instance"
  type        = string
}
 
variable "instance_size" {
  description = "Size of the boot disk for the compute instance (in GB)"
  type        = number
}
 
variable "webapp_bootdisk_type" {
  description = "Type of the boot disk for the compute instance"
  type        = string
}
 
variable "compute_instance_tags" {
  description = "Tags for the compute instance"
  type        = list(string)
}
 
variable "network_tier" {
  description = "Network tier for the compute instance"
  type        = string
}