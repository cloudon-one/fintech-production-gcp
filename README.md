# fintech Production Infrastructure - Terraform

This repository contains Terraform configuration for deploying a multi-project GCP infrastructure with shared VPC, GKE, SQL, data services, bastion host, and comprehensive IAM management as per the fintech production architecture.

## 🏗️ Architecture Overview

The infrastructure consists of:

- **Host Project**: Shared VPC host project (`fintech-prod-host-project`)
- **GKE Project**: Service project for GKE workloads (`fintech-prod-gke-project`)
- **Data Project**: Service project for data services and Cloud SQL (`fintech-prod-data-project`)

### Network Architecture

#### GKE VPC (10.60.0.0/16)

- **Nodes Subnet**: 10.60.4.0/22
- **Control Plane**: 10.60.1.0/28
- **Proxy Subnet**: 10.60.0.0/24 (Reserved for regional ILB)
- **Pod Secondary Range**: 10.60.128.0/17
- **Service Secondary Range**: 10.60.8.0/22

#### Data VPC (10.61.0.0/16)

- **Data Services Subnet**: 10.61.4.0/22
- **Proxy Subnet**: 10.61.0.0/24 (Reserved for regional ILB)

#### Service Network Segments for Google Private Connection

- **fintech-prod-private-sql**: 10.61.1.0/24
- **fintech-prod-private-sql-replica**: 10.61.2.0/24
- **fintech-prod-private-redis**: 10.61.12.0/24

#### Managed Airflow (Cloud Composer) for future considerations

- **Composer Pods Secondary Range**: 10.61.128.0/17
- **Composer Services Secondary Range**: 10.61.8.0/22

#### Bastion Host Network Configuration

- **Primary Interface**: Connected to GKE VPC (10.60.0.0/16) - gke-subnet
- **Secondary Interface**: Connected to Data VPC (10.61.0.0/16) - data-subnet
- **IP Forwarding**: Enabled for multi-VPC routing
- **IAP Tunnel**: Secure access via Google's IAP range (35.235.240.0/20)

## 📁 Project Structure

This project uses a **modular Terraform architecture** organized into service-specific directories:

```
├── api
│   └── api.yaml
├── docs
│   ├── GKE HLD.png
│   ├── SVPC.png
│   ├── VPC SC.png
│   ├── gke-lld.md
│   └── vpc-lld.md
├── modules
│   ├── terraform-google-bastion
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── startup-script.sh
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── terraform-google-cloudsql
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── terraform-google-gke
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   └── variables.tf
│   ├── terraform-google-iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── terraform-google-memorystore
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── terraform-google-svc-projects
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── terraform-google-svpc
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── terraform-google-vpc-sc
│       ├── main.tf
│       ├── outputs.tf
│       ├── README.md
│       └── variables.tf
├── net-bastion
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
├── net-iam
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
├── net-svpc
│   ├── backend.tf
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── proxy
│   │   ├── app-routing-config.md
│   │   ├── connection-test.sh
│   │   ├── create-proxy-vm.sh
│   │   ├── setup-proxy-fw.sh
│   │   ├── setup-proxy-svc.sh
│   │   ├── setup-proxy-vm.sh
│   │   └── troubleshoot.md
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
├── README.md
├── svc-gke
│   ├── backend.tf
│   ├── main.tf
│   ├── network-policies
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── modules
│   │   │   ├── api
│   │   │   │   └── main.tf
│   │   │   ├── backend
│   │   │   │   └── main.tf
│   │   │   ├── database
│   │   │   │   └── main.tf
│   │   │   ├── default
│   │   │   │   └── main.tf
│   │   │   ├── default-deny
│   │   │   │   └── main.tf
│   │   │   ├── frontend
│   │   │   │   └── main.tf
│   │   │   ├── monitoring
│   │   │   │   └── main.tf
│   │   │   └── production
│   │   │       └── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── test-network-policies.sh
│   │   └── variables.tf
│   ├── outputs.tf
│   ├── pod-security-standards
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   ├── rbac
│   │   ├── iam-bindings
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── submodules
│   │   │   │   └── kubernetes-prod-binding
│   │   │   │       └── main.tf
│   │   │   └── versions.tf
│   │   ├── iam-roles
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── submodules
│   │   │   │   ├── google-prod
│   │   │   │   │   └── main.tf
│   │   │   │   └── kubernetes-prod
│   │   │   │       └── main.tf
│   │   │   └── versions.tf
│   │   └── README.md
│   ├── README.md
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
├── svc-projects
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── svc-redis
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── variables.tf
│   └── versions.tf
├── svc-sql
│   ├── backend.tf
│   ├── cert
│   │   ├── client-cert.pem
│   │   ├── client-key.pem
│   │   ├── server-ca .pem
│   │   └── sql-admin.json
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
├── svc-vpcsc
│   ├── backend.tf
│   ├── main.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
```

### Architecture Benefits

- **Service Isolation**: Each service has its own directory and state
- **Modular Design**: Reusable modules for common patterns
- **Clear Dependencies**: Services depend on outputs from other services
- **Easy Maintenance**: Update specific services independently
- **Team Collaboration**: Different teams can work on different services
- **Security-First**: Bastion host and comprehensive IAM management
- **Access Control**: Multiple secure access methods (IAP, OS Login, SSH)

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.5.0
- Google Cloud SDK >= 524.0.0
- `jq` for JSON processing
- Appropriate GCP permissions:
  - **Billing Account**: `roles/billing.projectManager` on billing account
  - **Folder**: Project creation permissions in target folder
  - **APIs**: Enable required APIs in projects

### 1. Clone and Setup

```bash
git clone https://gitbub.com:fintech-prod-infrastructure.git
cd fintech-prod-infrastructure
```

### 2. Check Prerequisites

```bash
terraform version
gcloud version
jq --version
```

### 3. Initialize Infrastructure

```bash
cd svc-projects && terraform init
cd ../net-svcp && terraform init
cd ../net-iam && terraform init
cd ../net-bastion && terraform init
cd ../svc-gke && terraform init
cd ../svc-sql && terraform init
cd ../svc-redis && terraform init
cd ../svc-vpcsc && terraform init
```

### 4. Development Workflow

```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### 5. Deploy Infrastructure

⚠️ **CRITICAL**: Infrastructure must be deployed in this exact order due to dependencies:

#### 🎯 Deployment Sequence

1. **svc-projects** → Creates all GCP projects with random suffixes
2. **net-svcp** → Creates shared VPC networks (requires project IDs from step 1)
3. **net-iam** → Creates IAM resources (requires projects from step 1)
4. **net-bastion** → Creates secure bastion host (requires VPC from step 2 and IAM from step 3)
5. **svc-gke** → Creates GKE cluster (requires VPC from step 2 and IAM from step 3)
6. **svc-sql** → Creates Cloud SQL instances in data project (requires network from step 2)
7. **svc-redis** → Creates Redis instances in data project (requires network from step 2)
9. **svc-vpcsc** → Creates VPC Service Controls (requires all projects)

#### 🚀 Deployment Commands

```bash
cd svc-projects && terraform apply -auto-approve
cd ../net-svcp  && terraform apply -auto-approve
cd ../net-iam   && terraform apply -auto-approve
cd ../net-bastion && terraform apply -auto-approve
cd ../svc-gke   && terraform apply -auto-approve
cd ../svc-sql   && terraform apply -auto-approve
cd ../svc-redis && terraform apply -auto-approve
cd ../svc-vpcsc && terraform apply -auto-approve
```

#### 📋 Status Checking

```bash
cd svc-projects && terraform show
cd ../net-svpc  && terraform show
cd ../net-iam   && terraform show
cd ../net-bastion && terraform show
cd ../svc-gke   && terraform show
cd ../svc-sql   && terraform show
cd ../svc-redis && terraform show
cd ../svc-vpcsc && terraform show
```

## 📋 Service Dependencies

⚠️ **DEPLOYMENT ORDER REQUIREMENTS:**

1. **svc-projects** → Creates GCP projects (no dependencies)
   - Creates host, GKE, and data projects with random suffixes
   - Enables required APIs for each project
   - Must be deployed first

2. **net-svcp** → Creates network infrastructure (requires projects)
   - Creates shared VPC networks in host project
   - Configures subnets, NAT, firewall rules, VPC peering
   - Requires project IDs from step 1

3. **net-iam** → Creates IAM resources (requires projects)
   - Creates service accounts for GKE, Cloud SQL, and bastion
   - Configures Workload Identity for GKE
   - Sets up OS Login and IAP tunnel permissions
   - Requires project IDs from step 1

4. **net-bastion** → Creates secure bastion host (requires network and IAM)
   - Creates secured jump host for accessing private resources
   - Configures IAP tunnel access and SSH security
   - Requires VPC from step 2 and IAM from step 3
   - Optional: Can be skipped if bastion not needed

5. **svc-gke** → Creates GKE cluster (requires network and IAM)
   - Creates private GKE cluster in service project
   - Uses VPC and subnets from step 2
   - Uses service accounts from step 3
   - Optional: Can be skipped if GKE not needed

6. **svc-sql** → Creates Cloud SQL instances (requires network)
   - Creates MySQL and PostgreSQL instances in data project
   - Uses VPC network from step 2
   - Optional: Can be skipped if Cloud SQL not needed

7. **svc-redis** → Creates Redis instances in data project (requires network from step 2)
   - Optional: Can be skipped if Redis not needed

8. **svc-vpcsc** → Creates VPC Service Controls (requires all projects)
   - Configures VPC Service Controls for enhanced security
   - Requires all projects from previous steps
   - Optional: Can be skipped if VPC-SC not needed

## 🏭 Modules

This infrastructure uses modular Terraform design:

### Core Modules

- **`terraform-google-svpc`**: Shared VPC networks, subnets, NAT, firewall rules, VPC peering, DNS
- **`terraform-google-gke`**: Private GKE cluster with advanced security features and Workload Identity
- **`terraform-google-cloudsql`**: Cloud SQL instances with high availability, backup, and monitoring
- **`terraform-google-memorystore`**: Redis instances with private network, TLS encryption, and persistence
- **`terraform-google-svc-projects`**: GCP project creation, API enablement, and service account management
- **`terraform-google-vpc-sc`**: VPC Service Controls for enhanced security perimeter
- **`terraform-google-bastion`**: Secure bastion host with IAP tunnel support, SSH security, and monitoring
- **`terraform-google-iam`**: Comprehensive IAM management for GKE, Cloud SQL, OS Login, and IAP tunnel access

### Module Benefits

- **Reusability**: Use across multiple environments
- **Consistency**: Standardized resource creation
- **Testing**: Isolated testing of components
- **Maintenance**: Centralized updates and bug fixes
- **Security**: Built-in security best practices

## 🔧 Configuration

### Key Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `billing_account_id` | GCP Billing Account ID (format: XXXXXX-XXXXXX-XXXXXX) | - | ✅ |
| `folder_id` | GCP Organization Folder ID | `1234567890` | ✅ |
| `region` | Target region for all resources | `europe-central2` | ✅ |
| `enable_flow_logs` | Enable VPC flow logs for monitoring | `true` | - |
| `enable_private_google_access` | Enable Private Google Access for subnets | `true` | - |
| `enable_shared_vpc` | Enable Shared VPC configuration | `true` | - |
| `host_project_name` | Name of the host project | `fintech-prod-host-project` | ✅ |
| `gke_project_name` | Name of the GKE service project | `fintech-prod-gke-project` | ✅ |
| `data_project_name` | Name of the data service project | `fintech-prod-data-project` | ✅ |

### Service-Specific Configuration

Each service directory contains its own `terraform.tfvars` file:

- **`svc-projects/terraform.tfvars`**: Project creation settings (billing, folder, names)
- **`net-svcp/terraform.tfvars`**: Network and VPC configuration (subnets, firewall, DNS)
- **`net-iam/terraform.tfvars`**: IAM configuration (service accounts, roles, users)
- **`net-bastion/terraform.tfvars`**: Bastion host configuration (security, access, networking)
- **`svc-gke/terraform.tfvars`**: GKE cluster settings (node pools, security, networking)
- **`svc-sql/terraform.tfvars`**: Cloud SQL instances configuration (databases, users, replicas)
- **`svc-redis/terraform.tfvars`**: Redis instances configuration (memory, persistence, networking)
- **`svc-vpcsc/terraform.tfvars`**: VPC Service Controls configuration

⚠️ **Important**: After deploying `svc-projects`, update `net-svcp/terraform.tfvars` with the actual project ID (includes random suffix).

## 📝 Operations

### Development Workflow

```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```

### Service-Specific Operations

```bash
cd svc-projects && terraform init
cd ../net-svcp  && terraform init
cd ../net-iam   && terraform init
cd ../net-bastion && terraform init
cd ../svc-gke   && terraform init
cd ../svc-sql   && terraform init
cd ../svc-redis && terraform init
cd ../svc-vpcsc && terraform init

cd svc-projects && terraform apply -auto-approve
cd ../net-svcp  && terraform apply -auto-approve
cd ../net-iam   && terraform apply -auto-approve
cd ../net-bastion && terraform apply -auto-approve
cd ../svc-gke   && terraform apply -auto-approve
cd ../svc-sql   && terraform apply -auto-approve
cd ../svc-redis && terraform apply -auto-approve
cd ../svc-vpcsc && terraform apply -auto-approve
```

### Remote State Management

Each service maintains its own remote state:

- **Backend**: Google Cloud Storage
- **State Files**: Isolated per service
- **Locking**: Prevents concurrent modifications
- **Encryption**: State files are encrypted at rest

## 🗄️ Cloud SQL Infrastructure

### Database Instances

The Cloud SQL service (`svc-sql`) provides database instances deployed in the **data project**:

#### PostgreSQL Analytics Database

- **Version**: PostgreSQL 16
- **Availability**: Regional (high availability)
- **Databases**: `fintech_analytics`, `fintech_reporting`
- **Users**: `analytics_user`, `reporting_user`
- **Read Replicas**: Cross-region replica in europe-west1
- **Features**: Query insights, performance monitoring, maintenance windows

### Security Features

- **Private IP**: All instances use private IP addresses
- **VPC Integration**: Connected to fintech data VPC
- **SSL/TLS Enforcement**: All connections require SSL/TLS
- **Authorized Networks**: Restricted access to specific IP ranges
- **Deletion Protection**: Prevents accidental deletion
- **Backup Retention**: 7-day backup retention with point-in-time recovery

### Connection Information

```bash
# PostgreSQL connection
psql -h <private_ip> -U analytics_user -d fintech_analytics

# Cloud SQL Proxy
cloud_sql_proxy -instances=<connection_name>=tcp:5432
```

## 🗄️ Redis Infrastructure

### Redis Instances

The Redis service (`svc-redis`) provides Redis instances deployed in the **data project**:

#### Redis Cache Instance

- **Version**: Redis 7.0
- **Availability**: Regional (high availability)
- **Memory**: 1GB (configurable)
- **Features**: TLS encryption, persistence, maintenance windows
- **Private Network**: Connected to fintech data VPC (10.61.5.0/24)
- **Authentication**: AUTH enabled for secure access

### Security Features

- **Private IP**: All instances use private IP addresses
- **VPC Integration**: Connected to fintech data VPC
- **TLS Encryption**: All connections require TLS encryption
- **Authentication**: Redis AUTH enabled for access control
- **Deletion Protection**: Prevents accidental deletion
- **Persistence**: RDB snapshots enabled for data durability

### Connection Information

```bash
# Redis connection with TLS
redis-cli -h <private_ip> -p 6379 --tls --cert <cert_file> --key <key_file> -a <password>

# Redis connection without TLS (internal network)
redis-cli -h <private_ip> -p 6379 -a <password>
```

## 🔐 Bastion Host Infrastructure

### Secure Access Gateway

The bastion host (`net-bastion`) provides secure access to private resources:

#### Features

- **IAP Tunnel Support**: Secure access without public IP exposure
- **SSH Security**: Key-based authentication, fail2ban protection
- **OS Login Integration**: Centralized SSH access management via IAM
- **HTTPS Proxy**: Controlled internet access for internal resources
- **Monitoring**: Comprehensive logging and audit trails
- **Pre-installed Tools**: gcloud, kubectl, and other management tools
- **Multi-VPC Access**: Connected to both GKE and Data VPCs with IP forwarding enabled for comprehensive resource access

#### Network Architecture

The bastion host is deployed with multiple network interfaces for secure access to all VPCs:

- **Primary Interface**: Connected to GKE VPC (10.60.0.0/16) via gke-subnet
- **Secondary Interface**: Connected to Data VPC (10.61.0.0/16) via data-subnet
- **IP Forwarding**: Enabled to allow routing between VPCs
- **IAP Access**: Secure tunnel access from Google's IAP range (35.235.240.0/20)
- **Proxy Access**: Internal networks can use HTTPS proxy for internet access

#### Access Methods

1. **IAP Tunnel (Recommended)**:

   ```bash
   gcloud compute start-iap-tunnel fintech-prod-bastion 22 \
     --local-host-port=localhost:2222 \
     --zone=europe-central2-a \
     --project=fintech-prod-host-project-8hhr
   ssh -p 2222 user@localhost
   ```

2. **Direct SSH** (if authorized networks configured):

   ```bash
   gcloud compute ssh fintech-prod-bastion \
     --zone=europe-central2-a \
     --project=fintech-prod-host-project
   ```

3. **OS Login** (IAM-based access):
   ```bash
   gcloud compute ssh [USERNAME]@fintech-prod-bastion \
     --project=fintech-prod-host-project \
     --zone=europe-central2-a
   ```

#### GKE Cluster Access

From the bastion host, you can securely manage GKE clusters:

```bash
gcloud container clusters get-credentials fintech-prod-gke cluster --location europe-central2
kubectl get nodes
kubectl get pods --all-namespaces
```

## 📊 Outputs

Each service provides relevant outputs for other services:

### svc-projects outputs

- `host_project_id`, `gke_project_id`, `data_project_id` (with random suffixes)
- `gke_project_number`, `data_project_number`
- Service account emails for default compute accounts

### net-svcp outputs

- `host_project_id` (validated from input)
- `gke_network_id`, `gke_subnet_id`, `data_network_id`
- `gke_pods_secondary_range_name`, `gke_services_secondary_range_name`
- Network CIDR blocks and subnet details
- DNS zone information

### net-iam outputs

- `gke_workload_identity_service_accounts`: GKE workload identity service account emails
- `cloudsql_admin_service_account_email`: Cloud SQL admin service account email
- `gke_service_account_email`: GKE service account email
- `iap_tunnel_users`: List of users with IAP Tunnel access

### net-bastion outputs

- `bastion_instance_name`, `bastion_instance_id`
- `bastion_external_ip`, `bastion_internal_ip`
- `bastion_service_account_email`
- `bastion_ssh_command`, `bastion_iap_command`
- `bastion_router_name`, `bastion_nat_name`

### svc-gke outputs

- `cluster_name`, `cluster_endpoint`
- `cluster_ca_certificate`
- Node pool information

### svc-sql outputs

- `cloudsql_instances`: Map of Cloud SQL instances with connection details
- `cloudsql_private_ips`: Private IP addresses for database connections
- `cloudsql_databases`: Map of all databases across instances
- `cloudsql_users`: Map of all users across instances
- `cloudsql_read_replicas`: Map of read replicas for scalability

### svc-redis outputs

- Redis instance details

### svc-vpcsc outputs:

- Access policy ID and details
- Service perimeter configuration

## 🔐 Security

### Network Security

- **Private GKE Cluster**: No public endpoints
- **Private Cloud SQL**: All databases use private IP addresses
- **VPC Peering**: Secure inter-VPC communication
- **Firewall Rules**: Least privilege access
- **IAP Access**: OAuth-based authentication
- **Private Google Access**: No external IPs needed
- **Bastion Host**: Secure jump host with IAP tunnel support

### Database Security

- **SSL/TLS Enforcement**: All database connections encrypted
- **Private Network**: Databases only accessible via VPC
- **User Management**: Database-level access control
- **Backup Encryption**: Automated backups are encrypted
- **Deletion Protection**: Prevents accidental database deletion

### IAM Security

- **Service Account Isolation**: Dedicated SAs per service
- **Workload Identity**: Secure pod-to-GCP authentication  
- **Shared VPC Permissions**: Minimal required permissions
- **Project Separation**: Resource isolation by project
- **OS Login**: Centralized SSH access management
- **IAP Tunnel**: Secure access without public IP exposure

### Bastion Security

- **Key-based Authentication**: SSH keys only, no passwords
- **Fail2ban Protection**: Automatic brute force attack prevention
- **Audit Logging**: Complete activity audit trail
- **Network Restrictions**: Firewall rules limit access to authorized networks
- **Automatic Updates**: Unattended security updates
- **Deletion Protection**: Prevents accidental bastion deletion

## 🎯 Best Practices

This configuration follows Terraform and GCP best practices:

- **Remote State**: GCS backend with locking
- **Module Design**: Reusable, composable modules
- **Service Isolation**: Separate state files per service
- **Variable Validation**: Input validation with meaningful errors
- **Resource Naming**: Consistent naming conventions
- **Security**: Defense in depth, least privilege
- **Documentation**: Comprehensive inline and external docs
- **Access Control**: Multiple secure access methods
- **Monitoring**: Comprehensive logging and audit trails

## 🚨 Troubleshooting

### Common Issues

1. **Billing Account Permissions**

   ```bash
   # Error: missing permission billing.resourceAssociations.create
   # Grant Project Billing Manager role on billing account:
   gcloud beta billing accounts add-iam-policy-binding BILLING_ACCOUNT_ID \
     --member="user:EMAIL" --role="roles/billing.projectManager"
   ```

2. **Project ID Dependencies**

   ```bash
   # After deploying svc-projects, update net-svcp configuration:
   # Manually update net-svcp/terraform.tfvars with actual project ID
   ```

3. **State Lock Conflicts**

   ```bash
   # Using Terraform directly
   terraform force-unlock <lock-id>
   ```

4. **Module Not Found**

   ```bash
   terraform get -update
   terraform init -upgrade
   ```

5. **API Not Enabled**: APIs are automatically enabled during project creation

6. **Deployment Order Issues**

   ```bash
   # Ensure correct deployment order:
   # 1. svc-projects
   # 2. net-svcp
   # 3. net-iam
   # 4. net-bastion
   # 5. svc-gke
   # 6. svc-sql
   # 7. svc-redis
   # 8. svc-vpcsc
   ```

7. **Database Connection Issues**

   ```bash
   # Check firewall rules
   gcloud compute firewall-rules list --filter="name=allow-cloudsql-access"

   # Verify network connectivity
   gcloud compute instances describe <instance-name> --zone=<zone>
   ```

8. **Bastion Access Issues**

   ```bash
   # Check IAP tunnel status
   gcloud compute start-iap-tunnel fintech-prod-bastion 22 \
     --local-host-port=localhost:2222 \
     --zone=europe-central2-a \
     --project=fintech-prod-host-project-8hhr

   # Verify bastion instance status
   gcloud compute instances describe fintech-prod-bastion \
     --zone=europe-central2-a \
     --project=fintech-prod-host-project-8hhr

   # Check bastion service account permissions
   gcloud projects get-iam-policy fintech-prod-host-project-8hhr \
     --flatten="bindings[].members" \
     --format="table(bindings.role)" \
     --filter="bindings.members:bastion-prod-host@fintech-prod-host-project.iam.gserviceaccount.com"

   # Test network connectivity from bastion
   gcloud compute ssh fintech-prod-bastion \
     --zone=europe-central2-a \
     --project=fintech-prod-host-project-8hhr \
     --command="ping -c 3 10.60.4.1"
   ```

9. **Configuration Issues**

   ```bash
   # Validate configuration
   terraform validate
   
   # Check infrastructure status
   terraform show
   ```

### Debug Mode

```bash
export TF_LOG=DEBUG
terraform plan
```

### Support Resources

- [GCP Documentation](https://cloud.google.com/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Project Documentation](docs/)
- [Bastion Host Manual](net-bastion/README.md)

## 🔄 Maintenance

### Regular Tasks

1. **Provider Updates**: Update provider versions quarterly
2. **Security Reviews**: Monthly firewall and IAM audits  
3. **Cost Optimization**: Weekly resource usage reviews
4. **State Backup**: Automated daily state backups
5. **Documentation**: Keep LLD docs updated
6. **Bastion Maintenance**: Regular security updates and access reviews
7. **IAM Reviews**: Quarterly service account and permission audits

### Version Management

```bash
terraform version
terraform init -upgrade
terraform validate
```

## 📞 Support

For support and questions:

- Create an issue in this repository
- Contact the DevOps team

---

**Infrastructure Type**: Multi-Project GCP with Shared VPC, Cloud SQL, VPC Service Controls, Bastion Host, and Comprehensive IAM  
**Last Updated**: June 2025  
**Terraform Version**: >= 1.5.0  
**GCP Provider Version**: >= 5.45.0  
