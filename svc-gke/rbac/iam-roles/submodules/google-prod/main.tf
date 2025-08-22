data "terraform_remote_state" "svc_projects" {
  backend = "gcs"
  config = {
    bucket = "fintech-prod-tfstate"
    prefix = "svc-projects"
  }
}

locals {
  gke_project_id = data.terraform_remote_state.svc_projects.outputs.gke_project_id
}

resource "google_project_iam_binding" "container_viewers_devops" {
  project = local.gke_project_id
  role    = "roles/container.viewer"

  members = [
    "group:fintech-technology-devops@fintech.com",
  ]
}

resource "google_project_iam_binding" "container_developers" {
  project = local.gke_project_id
  role    = "roles/container.developer"

  members = [
    "group:fintech-technology-backend@fintech.com",
    "group:fintech-technology-frontend@fintech.com",
    "group:fintech-technology-mobile@fintech.com",
  ]
}

resource "google_project_iam_binding" "monitoring_viewers" {
  project = local.gke_project_id
  role    = "roles/monitoring.viewer"

  members = [
    "group:fintech-technology-qa@fintech.com",
    "group:fintech-technology-devops@fintech.com"
  ]
}

resource "google_project_iam_binding" "logging_viewers" {
  project = local.gke_project_id
  role    = "roles/logging.viewer"

  members = [
    "group:fintech-technology-devops@fintech.com",
    "group:fintech-technology-qa@fintech.com"
  ]
}