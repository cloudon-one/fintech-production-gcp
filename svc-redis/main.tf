provider "google" {
  region = var.region
}

data "terraform_remote_state" "net_svpc" {
  backend = "gcs"
  config = {
    bucket = var.net_svpc_backend_bucket
    prefix = var.net_svpc_backend_prefix
  }
}

data "terraform_remote_state" "svc_projects" {
  backend = "gcs"
  config = {
    bucket = var.svc_projects_backend_bucket
    prefix = var.svc_projects_backend_prefix
  }
}

data "terraform_remote_state" "net_iam" {
  backend = "gcs"
  config = {
    bucket = var.net_iam_backend_bucket
    prefix = var.net_iam_backend_prefix
  }
}

locals {
  data_project_id   = data.terraform_remote_state.svc_projects.outputs.data_project_id
  host_project_id   = data.terraform_remote_state.net_svpc.outputs.host_project_id
  data_network_id   = data.terraform_remote_state.net_svpc.outputs.data_network_id
  data_network_name = data.terraform_remote_state.net_svpc.outputs.data_network_name

  redis_instance_name = var.redis_config.instance_name_suffix != "" ? "fintech-prod-${var.redis_config.instance_name_suffix}" : "fintech-prod-redis"

  common_labels = merge(var.labels, {
    environment = "production"
    project     = "fintech-prod-data-project-mnch"
    managed_by  = "terraform"
    component   = "redis-memorystore"
  })
}

resource "google_project_service" "redis_api" {
  project = local.data_project_id
  service = "redis.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "servicenetworking_api" {
  project = local.data_project_id
  service = "servicenetworking.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

module "fintech_redis_instances" {
  for_each = var.redis_instances_config
  source   = "../modules/terraform-google-memorystore"

  project_id    = local.data_project_id
  instance_name = each.key == "main" ? local.redis_instance_name : "${local.redis_instance_name}-${each.key}"
  region        = var.region

  tier           = each.value.tier
  memory_size_gb = each.value.memory_size_gb
  redis_version  = each.value.redis_version

  authorized_network = local.data_network_id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  reserved_ip_range  = "fintech-prod-private-redis"

  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"

  maintenance_window = {
    day    = "SUNDAY" # Sunday
    hour   = 2        # 2 AM
    minute = 0
  }

  persistence_config = {
    persistence_mode    = "RDB"
    rdb_snapshot_period = "TWELVE_HOURS"
  }

  redis_configs = each.value.redis_configs

  replica_count      = each.value.replica_count
  read_replicas_mode = "READ_REPLICAS_ENABLED"

  user_labels = merge(local.common_labels, {
    cost_center = "fintech-technology-devops"
    owner       = "fintech-technology-devops"
    team        = "fintech-technology-devops"
  })

  depends_on = [
    google_project_service.redis_api,
    google_project_service.servicenetworking_api
  ]
}

resource "google_compute_firewall" "redis_access_from_gke" {
  name    = "allow-redis-access-from-gke"
  network = local.data_network_name
  project = local.host_project_id

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges      = ["10.60.0.0/16"]
  destination_ranges = ["10.61.12.0/28"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  description = "Allow Redis access from GKE cluster"
}

resource "google_compute_firewall" "redis_access_from_data" {
  name    = "allow-redis-access-from-data"
  network = local.data_network_name
  project = local.host_project_id

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges      = ["10.61.0.0/16"]
  destination_ranges = ["10.61.12.0/28"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  description = "Allow Redis access from data VPC"
}

resource "google_compute_firewall" "redis_access_from_iap" {
  name    = "allow-redis-access-from-iap"
  network = local.data_network_name
  project = local.host_project_id

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges      = ["35.235.240.0/20"]
  destination_ranges = ["10.61.12.0/28"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  description = "Allow Redis access from IAP tunnel"
} 