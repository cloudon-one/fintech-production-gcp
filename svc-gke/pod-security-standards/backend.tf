terraform {
  backend "gcs" {
    bucket = "fintech-prod-tfstate"
    prefix = "svc-gke/pod-security-standards"
  }
} 