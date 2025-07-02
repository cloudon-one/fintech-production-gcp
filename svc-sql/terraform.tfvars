labels = {
  environment = "production"
  team        = "fintech-technology-devops"
  cost_center = "fintech-technology-devops"
  owner       = "fintech-technology-devops"
}

sql_config = {
  enabled                    = true
  instance_name_suffix       = ""
  create_service_account     = true
  master_authorized_networks = []
}

sql_instances_config = {
  analytics = {
    database_version      = "POSTGRES_16"
    machine_type          = "db-perf-optimized-N-4"
    disk_type             = "PD_SSD"
    disk_size             = 250
    disk_autoresize       = true
    disk_autoresize_limit = 0
    availability_type     = "REGIONAL"
    primary_zone          = "europe-central2-b"
    deletion_protection   = true
    database_flags = [
      {
        name  = "cloudsql.iam_authentication"
        value = "on"
      },
      {
        name  = "max_connections"
        value = "200"
      },
      {
        name  = "shared_buffers"
        value = "2516582"
      },
      {
        name  = "cloudsql.enable_index_advisor"
        value = "on"
      },
      {
        name  = "cloudsql.enable_pgaudit"
        value = "on"
      }
    ]
    databases = {
      analytics_db = {
        name      = "fintech_analytics"
        charset   = "UTF8"
        collation = "en_US.UTF8"
      }
    }
    users = {
      analytics_user = {
        name     = "analytics_user"
        password = "XP&$ED%qfLmdm!A$"
      }
    }
    read_replicas = {
      replica = {
        region                = "europe-west3"
        zone                  = "europe-west3-c"
        machine_type          = "db-perf-optimized-N-2"
        disk_type             = "PD_SSD"
        disk_size             = 250
        disk_autoresize       = true
        disk_autoresize_limit = 0
        deletion_protection   = false
        ip_configuration = {
          ipv4_enabled        = false
          private_network     = null
          require_ssl         = true
          enable_private_path_for_google_cloud_services = true
          authorized_networks = []
        }
      }
    }
  }
}
 