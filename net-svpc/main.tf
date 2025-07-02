data "terraform_remote_state" "service_projects" {
  backend = "gcs"
  config = {
    bucket = "fintech-prod-terraform-state"
    prefix = "svc-projects"
  }
}
locals {
  gke_service_projects = {
    for k, v in data.terraform_remote_state.service_projects.outputs.service_projects : k => v.project_id
    if v.type == "gke"
  }
  
  data_service_projects = {
    for k, v in data.terraform_remote_state.service_projects.outputs.service_projects : k => v.project_id
    if v.type == "data"
  }
  
  gke_subnet_iam_bindings = {
    for subnet_name, subnet_config in var.gke_subnet_iam_bindings : subnet_name => {
      subnetwork = subnet_config.subnetwork
      region     = subnet_config.region
      members    = concat(
        subnet_config.members,
        [
          for project_key, project in data.terraform_remote_state.service_projects.outputs.service_projects :
          "serviceAccount:${project.default_service_account}"
          if project.type == "gke"
        ]
      )
    }
  }
  
  data_subnet_iam_bindings = {
    for subnet_name, subnet_config in var.data_subnet_iam_bindings : subnet_name => {
      subnetwork = subnet_config.subnetwork
      region     = subnet_config.region
      members    = concat(
        subnet_config.members,
        [
          for project_key, project in data.terraform_remote_state.service_projects.outputs.service_projects :
          "serviceAccount:${project.default_service_account}"
          if project.type == "data"
        ]
      )
    }
  }
}

module "gke_vpc" {
  source = "../modules/terraform-google-svpc"

  project_id = var.project_id
  vpc_name   = var.gke_vpc_name

  subnets = {
    gke           = merge(var.gke_subnet, { region = var.region })
    proxy         = merge(var.gke_proxy_subnet, { region = var.region })
    control-plane = merge(var.gke_control_plane_subnet, { region = var.region })
  }

  cloud_nat_config = var.gke_cloud_nat_config
  firewall_rules   = var.gke_firewall_rules
  vpc_peering_config = var.gke_vpc_peering_config
  enable_shared_vpc   = true
  service_projects    = local.gke_service_projects
  subnet_iam_bindings = local.gke_subnet_iam_bindings
  dns_config = var.dns_config
  dns_records = var.dns_records
  zone_name = "fintech-prod-internal"
  dns_name  = "fintech-prod.internal."
  gke_vpc_self_link  = "projects/${var.project_id}/global/networks/${var.gke_vpc_name}"
  data_vpc_self_link = "projects/${var.project_id}/global/networks/${var.data_vpc_name}"
  labels = var.labels
}

module "data_vpc" {
  source = "../modules/terraform-google-svpc"
  project_id = var.project_id
  vpc_name   = var.data_vpc_name
  subnets = {
    data  = merge(var.data_subnet, { region = var.region })
    proxy = merge(var.data_proxy_subnet, { region = var.region })
  }

  cloud_nat_config = var.data_cloud_nat_config
  firewall_rules   = var.data_firewall_rules
  vpc_peering_config = var.data_vpc_peering_config
  enable_shared_vpc   = true
  service_projects    = local.data_service_projects
  subnet_iam_bindings = local.data_subnet_iam_bindings
  private_service_access_ranges = var.data_private_service_access_ranges
  dns_config = var.dns_config
  dns_records = var.dns_records
  zone_name = "fintech-prod-internal"
  dns_name  = "fintech-prod.internal."
  gke_vpc_self_link  = "projects/${var.project_id}/global/networks/${var.gke_vpc_name}"
  data_vpc_self_link = "projects/${var.project_id}/global/networks/${var.data_vpc_name}"
  labels = var.labels
}

 