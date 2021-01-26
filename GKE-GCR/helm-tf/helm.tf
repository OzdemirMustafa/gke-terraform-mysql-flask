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

  backend "gcs" {
    bucket = "gke-terraform-helm-python"
    prefix = "terraform/helm"
  }
}

provider "google" {
  version = "3.47.0"
  region  = "europe-west3"
}

variable "project" {default = "robotic-jet-301718"}
variable "region" { default = "europe-west3" }
variable "cluster_name" {default = "gke-tf-cluster"}


data "google_client_config" "current" {}

data "google_container_cluster" "gke" {
    name     = var.cluster_name
    location = var.region
    project  = var.project
}

provider "kubernetes" {
  load_config_file = false

  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}

resource "helm_release" "flaskapp" {
  name       = "flaskapp"
  chart      = "./flaskapp"
}