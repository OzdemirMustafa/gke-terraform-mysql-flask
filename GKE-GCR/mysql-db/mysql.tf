
provider "google" {
  project     = "robotic-jet-301718"
  region      = "europe-west3"
}

locals {
  onprem = ["212.154.55.130","78.191.2.231"]
}


resource "google_sql_database_instance" "master" {
  name = "mysql-instance"
  database_version = "MYSQL_5_6"
  region = "europe-west3"
  project = "robotic-jet-301718"


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
  name = "mysql"
  instance = google_sql_database_instance.master.name
  password = "UbX4YmyuCzxKrQ"
  project = "robotic-jet-301718"

}
