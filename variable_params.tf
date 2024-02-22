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
