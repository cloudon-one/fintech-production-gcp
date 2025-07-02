# Resource type

- Shared VPC Host Project Name: fintech-prod-svpc-host-<random-string>
- GKE Project Name: fintech-prod-gke-svc-<random-string>
- Data Project Name: fintech-prod-data-svc-<random-string>
- GKE Cluster Name: fintech-prod-gke-cluster
- Cloud SQL Instance Name: fintech-prod-sql-<service-name>
- GKE VPC CIDR Block: 10.60.0.0/16
- Nodes Subnet CIDR Block (gke-subnet): 10.60.4.0/22
- GKE Control Plane  CIDR Block (gke-vpc): 10.60.1.0/28
- Proxy-only Subnet CIDR Block (gke-vpc): 10.60.0.0/24
- Pod Secondary Range (gke-vpc): 10.60.128.0/17
- Service Secondary Range (gke-vpc): 10.60.8.0/22
- Data VPC CIDR Block: 10.61.0.0/16
- Data services CIDR block (data-subnet): 10.61.4.0/22
- Composer Pods Secondary Range (data-subnet): 10.61.128.0/17
- Composer Services Secondary Range (data-subnet): 10.61.8.0/22
- Proxy-only Subnet CIDR Block (data-vpc): 10.61.0.0/24
- Redis subnet CIDR: 10.61.3.0/24
- DNS Zone Name: fintech-prod.internal