terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }
  }

  backend "gcs"{
    bucket = "terraform-second"
    prefix = "terraform/case"
  }
}

provider "google" {
  version = "3.47.0"
  region  = "europe-west3"
}

variable "project" {default = "robotic-jet-301718"}
variable "region" { default = "europe-west3" }
variable "cluster_name" {default = "gke-tf-cluster"}
variable "network" { default = "default" }
variable "subnetwork" { default = "" }
variable "ip_range_pods" { default = "" }
variable "ip_range_services" { default = "" }

module "gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google"
  version                  = "12.0.0"
  project_id               = var.project
  name                     = var.cluster_name
  region                   = var.region
  zones                    = ["europe-west3-a"]
  network                  = var.network
  subnetwork               = var.subnetwork
  ip_range_pods            = var.ip_range_pods
  ip_range_services        = var.ip_range_services
  kubernetes_version       = "1.16.15-gke.6000"
  create_service_account   = false
  remove_default_node_pool = true

  node_pools = [{
    name               = "microservices"
    machine_type       = "n1-standard-1"
    min_count          = 1
    max_count          = 5
    initial_node_count = 2
  }]

  node_pools_oauth_scopes = {
    all = []
    microservices = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}

data "google_client_config" "current" {

}

provider "kubernetes" {
  load_config_file = false

  host                   = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  token                  = data.google_client_config.current.access_token
}

resource "google_container_registry" "registry" {
  project  = var.project
  location = "EU"
}

resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_container_registry.registry.id
  role = "roles/storage.objectViewer"
  member = "user:mustafa.ozdemir.dev@gmail.com"
}