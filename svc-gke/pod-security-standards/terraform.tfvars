region       = "europe-central2"
project_id   = "fintech-prod-gke-project"
cluster_name = "fintech-prod-gke-cluster"

# kubeconfig_path = "~/.kube/config"

pod_security_standards_config = {
  mode    = "ENFORCED"
  version = "v1.32"
}