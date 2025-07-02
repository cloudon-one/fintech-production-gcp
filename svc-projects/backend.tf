terraform {
  backend "gcs" {
    bucket = "fintech-prod-tfstate"
    prefix = "svc-projects"
  }
}