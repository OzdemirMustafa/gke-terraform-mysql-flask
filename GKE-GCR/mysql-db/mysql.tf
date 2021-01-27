provider "google" {
  project     = "robotic-jet-301718"
  region      = "europe-west3"
}

variable "password" { default = "" }

locals {
  onprem = ["34.91.134.8","77.92.114.18","85.100.66.45"]
}


resource "google_sql_database_instance" "master" {
  name = "mysqldb-instance"
  database_version = "MYSQL_5_6"
  region = "europe-west3"
  project = "robotic-jet-301718"
  deletion_protection = false
  

  settings {
    tier = "db-f1-micro"
    disk_autoresize = "false"
    disk_size = 10
    disk_type = "PD_HDD"


    ip_configuration {
      require_ssl = "false"
      ipv4_enabled = "true"
      dynamic "authorized_networks" {
        for_each = local.onprem
        iterator = onprem

        content {
          name = "onprem-${onprem.key}"
          value = onprem.value
        }
        
      }
    }
  }
}

resource "google_sql_user" "mysql" {
  name = "mysqluser"
  instance = google_sql_database_instance.master.name
  password = var.password
  project = "robotic-jet-301718"  

}
