billing_account_id = "123456-789012-345678"
folder_id          = "12345678901234567890"

labels = {
  environment = "production"
  team        = "fintech-technology-devops"
  cost_center = "fintech-technology-devops"
  owner       = "fintech-technology-devops"
}

host_project_name = "fintech-prod-host-project"

service_projects = {
  gke = {
    name = "fintech-prod-gke-project"
    type = "gke" # connect to gke-vpc
    apis = [] # Uses default APIs for gke type
  }
  data = {
    name = "fintech-prod-data-project"
    type = "data" # connect to data-vpc
    apis = [] # Uses default APIs for data type
  }
}