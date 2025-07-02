terraform {
  backend "gcs" {
    bucket = "fintech-prod-tfstate-bucket"
    prefix = "net-bastion"
  }
} 