# GCP Logs Explorer Queries for User Activity and Terraform Detection

## Basic User and Service Account Filtering

### 1. Filter Activities by Specific User
```
protoPayload.authenticationInfo.principalEmail=""
```

### 2. Filter Activities by Service Account
```
protoPayload.authenticationInfo.principalEmail:"@serviceaccount.com"
```

### 3. Filter Activities by Multiple Users
```
protoPayload.authenticationInfo.principalEmail=("y.naumenko@iceo.co" OR "user2@domain.com" OR "user3@domain.com")
```

### 4. Exclude Service Accounts (Human Users Only) 
```
NOT protoPayload.authenticationInfo.principalEmail:"gserviceaccount.com"
```

### 5. Filter by bastion Service Account Pattern (any SA)
```
protoPayload.authenticationInfo.principalEmail:"bastion-prod-host@beone-prod-host-project-8hhr.iam.gserviceaccount.com"
```

## Time-Based Queries

### 6. Activities in Last Hour
```
timestamp >= "2025-06-30T10:00:00Z"
protoPayload.authenticationInfo.principalEmail="o"
```

### 7. Activities in Specific Time Window (Today)
```
timestamp >= "2025-06-30T09:00:00Z" AND timestamp <= "2025-06-30T17:00:00Z"
protoPayload.authenticationInfo.principalEmail=""
```

## Terraform Plan Detection

```
protoPayload.authenticationInfo.principalEmail=""
AND (
  protoPayload.methodName=~".*\.(get|list)$"
  AND (
    protoPayload.serviceName="compute.googleapis.com" OR 
    protoPayload.serviceName="container.googleapis.com" OR 
    protoPayload.serviceName="sqladmin.googleapis.com" OR 
    protoPayload.serviceName="storage.googleapis.com" OR 
    protoPayload.serviceName="iam.googleapis.com"
  )
)
AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2025-06-30T10:30:00Z"
```

## Terraform Apply Detection Queries

### 12. VPC-Related Terraform Apply Detection
```
protoPayload.authenticationInfo.principalEmail=""
AND (
  protoPayload.methodName=("compute.networks.insert" OR 
                          "compute.networks.patch" OR 
                          "compute.networks.delete" OR 
                          "compute.subnetworks.insert" OR 
                          "compute.subnetworks.patch" OR 
                          "compute.subnetworks.delete" OR 
                          "compute.forwardingRules.insert" OR 
                          "compute.forwardingRules.delete" OR 
                          "compute.backendServices.insert" OR 
                          "compute.backendServices.patch" OR 
                          "compute.backendServices.delete")
)
AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2025-06-30T11:00:00Z"
```

### 13. GKE-Related Terraform Apply Detection
```
protoPayload.authenticationInfo.principalEmail=""
AND (
  protoPayload.methodName=("container.clusters.create" OR 
                          "container.clusters.update" OR 
                          "container.clusters.delete" OR 
                          "container.nodePools.create" OR 
                          "container.nodePools.update" OR 
                          "container.nodePools.delete")
)
AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2025-06-30T11:00:00Z"
```

### 14. Cloud SQL Terraform Apply Detection
```
protoPayload.authenticationInfo.principalEmail="y.naumenko@iceo.co"
AND (
  protoPayload.methodName=("cloudsql.instances.create" OR 
                          "cloudsql.instances.patch" OR 
                          "cloudsql.instances.delete" OR 
                          "cloudsql.databases.insert" OR 
                          "cloudsql.databases.delete" OR 
                          "cloudsql.users.insert" OR 
                          "cloudsql.users.update" OR 
                          "cloudsql.users.delete")
)
AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2025-06-30T11:00:00Z"
```

## Advanced Pattern Detection

### 15. Detect Terraform Plan + Apply Sequence
```
protoPayload.authenticationInfo.principalEmail="y.naumenko@iceo.co"
AND (
  (protoPayload.methodName=~".*\.(get|list)$" AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2025-06-30T10:30:00Z") OR
  (protoPayload.methodName=~".*\.(create|insert|patch|update|delete)$" AND timestamp >= "2025-06-30T10:30:00Z" AND timestamp <= "2025-06-30T11:00:00Z")
)
AND protoPayload.serviceName="compute.googleapis.com"
```

### 16. High-Volume Read Operations (Likely Terraform Plan)
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.methodName=~".*\.(get|list)$"
AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2025-06-30T10:05:00Z"
```

### 17. Detect Resource State Checks (Terraform Refresh)
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.methodName=~".*\.get$"
AND (
  protoPayload.resourceName=~"projects/.*/zones/.*/instances/.*" OR
  protoPayload.resourceName=~"projects/.*/global/networks/.*" OR
  protoPayload.resourceName=~"projects/.*/regions/.*/subnetworks/.*"
)
AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2025-06-30T10:30:00Z"
```

## Service-Specific Queries
`

### 19. Storage-Related Activities
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="storage.googleapis.com"
AND (
  protoPayload.methodName=("storage.buckets.create" OR 
                          "storage.buckets.delete" OR 
                          "storage.buckets.get" OR 
                          "storage.buckets.list" OR 
                          "storage.objects.create" OR 
                          "storage.objects.delete")
)
```

### 20. Kubernetes Engine Extended Query
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="container.googleapis.com"
AND (
  protoPayload.resourceName=~"projects/.*/zones/.*/clusters/.*" OR
  protoPayload.resourceName=~"projects/.*/locations/.*/clusters/.*"
)
AND timestamp >= "2025-06-30T10:00:00Z"
```

## Combined Queries for Terraform Detection

### 21. User Activity Summary with Resource Counts
```
protoPayload.authenticationInfo.principalEmail="user@domain.com"
AND timestamp >= "2025-06-30T09:00:00Z"
AND (
  protoPayload.serviceName=("compute.googleapis.com" OR 
                           "container.googleapis.com" OR 
                           "sqladmin.googleapis.com" OR 
                           "storage.googleapis.com")
)
```

### 22. Terraform Plan Detection with Resource Type Breakdown
```
protoPayload.authenticationInfo.principalEmail="user@domain.com"
AND protoPayload.methodName=~".*\.(get|list)$"
AND timestamp >= "2025-06-30T10:00:00Z" AND timestamp <= "2024-01-01T10:30:00Z"
AND (
  (protoPayload.serviceName="compute.googleapis.com" AND protoPayload.resourceName=~"projects/.*/global/networks/.*") OR
  (protoPayload.serviceName="compute.googleapis.com" AND protoPayload.resourceName=~"projects/.*/regions/.*/subnetworks/.*") OR
  (protoPayload.serviceName="container.googleapis.com" AND protoPayload.resourceName=~"projects/.*/zones/.*/clusters/.*") OR
  (protoPayload.serviceName="sqladmin.googleapis.com" AND protoPayload.resourceName=~"projects/.*/instances/.*")
)
```

## Terraform plan VPC staff

```
resource.type="gce_project"
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="compute.googleapis.com"
AND (
  protoPayload.methodName:("networks.get" OR 
                          "subnetworks.get" OR 
                          "subnetworks.list" OR 
                          "networks.list" OR 
                          "forwardingRules.get" OR 
                          "forwardingRules.list" OR 
                          "backendServices.get" OR 
                          "backendServices.list" OR 
                          "urlMaps.get" OR 
                          "urlMaps.list" OR 
                          "targetHttpProxies.get" OR 
                          "targetHttpsProxies.get" OR 
                          "globalForwardingRules.get" OR 
                          "routers.get" OR 
                          "routers.list" OR 
                          "vpnGateways.get" OR 
                          "vpnTunnels.get")
)
AND timestamp >= "2025-06-30T10:00:00Z" 
AND timestamp <= "2025-06-30T10:30:00Z"
```

### Debugging Steps:

#### Step 1: Check if user has any activity
```
protoPayload.authenticationInfo.principalEmail=""
AND timestamp >= "2025-06-30T10:00:00Z" 
AND timestamp <= "2025-06-30T10:30:00Z"
```

#### Step 2: Check compute service activity
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="compute.googleapis.com"
AND timestamp >= "2025-06-30T10:00:00Z" 
AND timestamp <= "2025-06-30T10:30:00Z"
```

#### Step 3: Find actual method names
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="compute.googleapis.com"
AND protoPayload.methodName=~".*get.*"
AND timestamp >= "2025-06-30T10:00:00Z" 
AND timestamp <= "2025-06-30T10:30:00Z"
```

### Alternative Method Name Formats to Try:

#### Version 1: Without compute prefix
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="compute.googleapis.com"
AND (
  protoPayload.methodName=("v1.compute.networks.get" OR 
                          "v1.compute.subnetworks.get" OR 
                          "v1.compute.subnetworks.list" OR 
                          "v1.compute.networks.list")
)
AND timestamp >= "2025-06-30T10:00:00Z" 
AND timestamp <= "2025-06-30T10:30:00Z"
```

#### Version 2: Using regex pattern
```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="compute.googleapis.com"
AND protoPayload.methodName=~".*(networks|subnetworks|forwardingRules|backendServices)\.(get|list).*"
AND timestamp >= "2025-06-30T10:00:00Z" 
AND timestamp <= "2025-06-30T10:30:00Z"
```

#### Version 3: Broader search

```
protoPayload.authenticationInfo.principalEmail=""
AND protoPayload.serviceName="compute.googleapis.com"
AND protoPayload.methodName=~".*\.(get|list)$"
AND timestamp >= "2025-06-30T10:00:00Z" 
AND timestamp <= "2025-06-30T10:30:00Z"
```

**Key Method Name Corrections:**
- `compute.networks.get` → `v1.compute.networks.get`
- `container.clusters.list` → `google.container.v1beta1.ClusterManager.ListClusters`
- Add `protoPayload.serviceName` filters for better performance

## Usage Tips

### Time Window Considerations

- **Terraform Plan**: Usually completes within 5-30 minutes depending on infrastructure size
- **Terraform Apply**: Can take 10 minutes to several hours
- Use shorter time windows (5-15 minutes) for plan detection
- Use longer time windows (30 minutes to 2 hours) for apply detection

### Pattern Recognition

- **High GET/LIST operations in short timeframe** = Likely Terraform Plan
- **Mix of GET followed by CREATE/UPDATE/DELETE** = Likely Terraform Apply
- **Regular intervals of same operations** = Likely automated/scheduled runs

### Filtering Best Practices

- Always include user/service account filters to reduce noise
- Use timestamp ranges to focus on specific deployment windows
- Combine service names with method patterns for precise detection
- Monitor for both success and error responses to catch failed deployments
