# (C) Copyright 2024 Hewlett Packard Enterprise Development LP
terraform {
  required_providers {
    hpegl = {
      source  = "HPE/hpegl"
      version = ">= 0.3.12"
    }
  }
}

provider "hpegl" {
  # metal block for configuring bare metal resources.
  metal {
    gl_token   = false
    rest_url = "https://client.greenlake.hpe.com/api/metal" 
    space_name = var.space
    project_id = var.project_id
  }
}

# Project == Compute Group "CTOTesting"
variable "project_id" {
    type = string
    description = "Project ID"
    default = "ac4994e1-17dd-4592-a376-733b1ec5544e" 
}


variable "space" {
    type = string
    description = "Space"
    default = "Hosted-Trial-EPCPCE1-Space"
}

variable "location"{
    type = string
    description = "Target location for filtering networks and volumes"
    default = "Switzerland:EMEA:Geneva-EPC-PCE1"
}

variable "rest_url" {
    type = string
    description = "REST URL"
    default = "https://client.greenlake.hpe.com/api/metal"
}

resource "random_integer" "random" {
  min = 1
  max = 50000
}

resource "hpegl_metal_ssh_key" "HPE_John" {
  name       = "HPE_key_${random_integer.random.result}"
  public_key = "ssh-rsa <redacted>"
}

resource "hpegl_metal_network" "hpenet" {
  name        = "hpe_john_net_${random_integer.random.result}"
  description = "New private network ${random_integer.random.result} description"
  location    = var.location
  ip_pool {
    name          = "hpe_johnl_pool"
    description   = "New IP pool description"
    ip_ver        = "IPv4"
    base_ip       = "10.0.0.0"
    netmask       = "/24"
    default_route = "10.0.0.1"
    sources {
      base_ip = "10.0.0.3"
      count   = 10
    }
    dns      = ["10.0.0.50"]
    proxy    = "https://10.0.0.60"
    no_proxy = "10.0.0.5"
    ntp      = ["10.0.0.80"]
  }
}


resource "hpegl_metal_host" "demo_advance" {
  count = 1
  name             = "HPE-demo-advance-${random_integer.random.result}"
  image            = "RHEL@9.0-20240924-BYOI"
  machine_size     = "M2i"
  ssh              = [hpegl_metal_ssh_key.HPE_John.id]
  networks         = ["GL Metal Telemetry"]
  network_route    = "GL Metal Telemetry" 
  network_untagged = "GL Metal Telemetry" 
  location         = var.location
  description      = "Hello from Terraform"
  # Attaching tags

  labels           = { "purpose" = "devops" }
}
