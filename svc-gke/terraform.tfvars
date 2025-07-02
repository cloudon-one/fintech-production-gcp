# GKE Security Group for RBAC
gke_security_group = "gke-security-groups@cloudon-one.com"

gke_config = {
  enabled                = true
  cluster_name_suffix    = "cluster"
  region                 = "europe-central2"
  network                = "gke-vpc"
  subnetwork             = "gke-subnet"
  master_ipv4_cidr_block = "10.60.1.0/28"
  master_authorized_networks = [
    {
      cidr_block   = "10.60.0.0/16"
      display_name = "gke-vpc"
    },
    {
      cidr_block   = "10.61.0.0/16"
      display_name = "data-vpc"
    },
    {
      cidr_block   = "104.192.136.0/21"
      display_name = "bitbucket-pipleines-1"
    },
    {
      cidr_block   = "185.166.140.0/22"
      display_name = "bitbucket-pipleines-2"
    },
    {
      cidr_block   = "13.200.41.128/25"
      display_name = "bitbucket-pipleines-3"
    },
  ]
  enable_private_endpoint           = false
  enable_private_nodes              = true
  enable_workload_identity          = true
  enable_network_policy             = false
  enable_http_load_balancing        = true
  enable_horizontal_pod_autoscaling = true
  enable_vertical_pod_autoscaling   = true
  enable_cloud_monitoring           = true
  enable_cloud_logging              = true
  enable_node_auto_provisioning     = true
  enable_burst_scaling              = true
  release_channel                   = "STABLE"
  deletion_protection               = true
  create_service_account            = true
  workload_identity_service_accounts = {
    data-processor = {
      display_name               = "Data Processing Service Account"
      description                = "Service account for data processing jobs and workloads"
      kubernetes_namespace       = "default"
      kubernetes_service_account = "data-processor-sa"
      gcp_roles = [
        "roles/storage.objectViewer",
        "roles/storage.objectCreator",
        "roles/cloudsql.client",
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser"
      ]
    }
    beone-app = {
      display_name               = "Application Service Account"
      description                = "Service account for general application workloads"
      kubernetes_namespace       = "production"
      kubernetes_service_account = "beone-app-sa"
      gcp_roles = [
        "roles/storage.objectViewer",
        "roles/cloudsql.client",
        "roles/secretmanager.secretAccessor"
      ]
    }
    beone-monitoring = {
      display_name               = "Monitoring Service Account"
      description                = "Service account for monitoring and observability workloads"
      kubernetes_namespace       = "monitoring"
      kubernetes_service_account = "monitoring-sa"
      gcp_roles = [
        "roles/monitoring.metricWriter",
        "roles/logging.logWriter",
        "roles/cloudtrace.agent"
      ]
    }
  }
  timeouts = {
    cluster_timeout   = "45m"
    node_pool_timeout = "30m"
  }
  maintenance_window = {
    daily_window_start_time = "03:00"
    recurring_window = {
      start_time = "2025-01-01T03:00:00Z"
      end_time   = "2026-01-01T05:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }
  security = {
    enable_shielded_nodes       = true
    enable_secure_boot          = true
    enable_integrity_monitoring = true
    enable_confidential_nodes   = true
    pod_security_standards = {
      mode    = "ENFORCED"
      version = "v1.32"
    }
  }
  monitoring = {
    enable_managed_prometheus = true
    logging_service           = "logging.googleapis.com/kubernetes"
    monitoring_service        = "monitoring.googleapis.com/kubernetes"
    logging_config = {
      enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
      retention_days    = 365
    }
    monitoring_config = {
      enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]
      managed_prometheus = {
        enabled = true
      }
    }
  }
  backup_config = {
    enabled = true
    schedule = {
      incremental_interval = "6h"
      full_interval        = "24h"
      retention_days       = 1825
    }
  }
}

gke_node_pools_config = {
  app = {
    name         = "app-pool"
    node_count   = 3
    machine_type = "n2d-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-balanced"
    zones        = ["europe-central2-a", "europe-central2-b", "europe-central2-c"]
    autoscaling = {
      min_node_count  = 3
      max_node_count  = 9
      location_policy = "BALANCED"
    }
    management = {
      auto_repair  = true
      auto_upgrade = true
      maintenance_window = {
        start_time = "03:00"
        end_time   = "05:00"
        recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
      }
    }
    labels = {
      node-pool   = "app"
      environment = "production"
    }
    taints = []
    security = {
      enable_secure_boot            = true
      enable_integrity_monitoring   = true
      enable_confidential_computing = true
    }
    workload_config = {
      workload_identity_config = {
        workload_pool = "beone-prod-gke-project-3ypz.svc.id.goog"
      }
      resource_limits = {
        cpu    = "2"
        memory = "8Gi"
      }
      resource_requests = {
        cpu    = "1"
        memory = "4Gi"
      }
      pod_disruption_budget = {
        min_available = 2
      }
    }
  }
  service = {
    name         = "service-pool"
    node_count   = 2
    machine_type = "n2d-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-balanced"
    zones        = ["europe-central2-a", "europe-central2-b", "europe-central2-c"]
    autoscaling = {
      min_node_count  = 2
      max_node_count  = 6
      location_policy = "BALANCED"
    }
    management = {
      auto_repair  = true
      auto_upgrade = true
      maintenance_window = {
        start_time = "03:00"
        end_time   = "05:00"
        recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
      }
    }
    labels = {
      node-pool   = "service"
      environment = "production"
    }
    taints = []
    security = {
      enable_secure_boot            = true
      enable_integrity_monitoring   = true
      enable_confidential_computing = true
    }
    workload_config = {
      workload_identity_config = {
        workload_pool = "beone-prod-gke-project-3ypz.svc.id.goog"
      }
      resource_limits = {
        cpu    = "2"
        memory = "4Gi"
      }
      resource_requests = {
        cpu    = "1"
        memory = "2Gi"
      }
      pod_disruption_budget = {
        min_available = 2
      }
    }
  }
}

labels = {
  environment = "production"
  project     = "beone-prod-gke-project-3ypz"
  cost_center = "beone-production"
  owner       = "beone-technology-devops"
  managed_by  = "terraform"
}