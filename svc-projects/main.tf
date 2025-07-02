resource "random_string" "host_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "random_string" "gke_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "random_string" "data_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "random_string" "service_project_suffixes" {
  for_each = { for k, v in var.service_projects : k => v if !contains(["gke", "data"], k) }
  
  length  = 4
  special = false
  upper   = false
}

module "service_projects" {
  source = "../modules/terraform-google-svc-projects"

  billing_account_id               = var.billing_account_id
  folder_id                        = var.folder_id
  labels                           = var.labels
  disable_default_network_creation = var.disable_default_network_creation

  host_project = {
    name   = var.host_project_name
    suffix = random_string.host_suffix.result
    apis   = var.host_project_apis
  }

  service_projects = {
    for key, project in var.service_projects : key => {
      name   = project.name
      suffix = key == "gke" ? random_string.gke_suffix.result : (
        key == "data" ? random_string.data_suffix.result : 
        random_string.service_project_suffixes[key].result
      )
      type   = project.type
      apis   = project.apis
    }
  }
}