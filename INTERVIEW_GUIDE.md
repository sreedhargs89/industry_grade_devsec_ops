# 🎯 DevSecOps & Kubernetes Interview Guide
## Complete Question Bank with Detailed Answers

---

# 📋 Table of Contents

1. [Infrastructure & Cloud (AWS)](#1-infrastructure--cloud-aws)
2. [Containerization & Docker](#2-containerization--docker)
3. [Kubernetes Core Concepts](#3-kubernetes-core-concepts)
4. [Kubernetes Networking](#4-kubernetes-networking)
5. [Configuration Management (Ansible)](#5-configuration-management-ansible)
6. [Monitoring & Observability](#6-monitoring--observability)
7. [Security & Best Practices](#7-security--best-practices)
8. [Troubleshooting Scenarios](#8-troubleshooting-scenarios)
9. [System Design Questions](#9-system-design-questions)

---

# 1. Infrastructure & Cloud (AWS)

## 🏗️ Fundamental Questions

### Q1: What is Infrastructure as Code (IaC) and why is it important?

**Answer:**
Infrastructure as Code is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

**Benefits:**
- **Version Control**: Infrastructure changes are tracked like code
- **Repeatability**: Same infrastructure can be deployed multiple times
- **Documentation**: Infrastructure is self-documenting
- **Collaboration**: Team can review infrastructure changes
- **Testing**: Infrastructure can be tested before deployment
- **Speed**: Faster provisioning compared to manual processes

**Tools:**
- **Terraform**: Platform-agnostic provisioning
- **CloudFormation**: AWS-native IaC
- **Pulumi**: Multi-language infrastructure code
- **ARM Templates**: Azure-native IaC

---

### Q2: Explain VPC, Subnets, and Security Groups in AWS

**Answer:**

**VPC (Virtual Private Cloud):**
- Logically isolated network in AWS
- Provides complete control over network environment
- Spans multiple Availability Zones
- Default CIDR: 10.0.0.0/16 (65,536 IPs)

**Subnets:**
- Subdivision of VPC IP range
- Can be public (internet gateway) or private (NAT gateway)
- Must be within single AZ
- Example: 10.0.1.0/24 (256 IPs)

**Security Groups:**
- Virtual firewall for EC2 instances
- **Stateful**: Return traffic automatically allowed
- Rules specify allowed traffic (protocol, port, source)
- Default: All outbound allowed, no inbound allowed

**Example Configuration:**
```yaml
VPC: 10.0.0.0/16
├── Public Subnet: 10.0.1.0/24 (AZ-1a)
├── Private Subnet: 10.0.2.0/24 (AZ-1b)
└── Security Group:
    ├── SSH (22) from 0.0.0.0/0
    ├── HTTP (80) from 0.0.0.0/0
    └── HTTPS (443) from 0.0.0.0/0
```

---

### Q3: How would you secure an AWS environment?

**Answer:**

**Identity and Access Management:**
- **IAM Roles**: Service-to-service authentication
- **Least Privilege**: Minimum required permissions
- **MFA**: Multi-factor authentication for users
- **Access Keys**: Rotate regularly, use temporary credentials

**Network Security:**
- **Security Groups**: Restrictive inbound rules
- **NACLs**: Subnet-level firewall (stateless)
- **VPC Flow Logs**: Network traffic monitoring
- **Private Subnets**: Keep internal resources isolated

**Data Protection:**
- **Encryption**: At rest (EBS, S3) and in transit (TLS)
- **KMS**: Key management for encryption
- **Secrets Manager**: Secure credential storage
- **Backup Strategy**: Regular snapshots and backups

**Monitoring and Compliance:**
- **CloudTrail**: API call logging
- **GuardDuty**: Threat detection
- **Config**: Resource compliance monitoring
- **Security Hub**: Central security findings

---

# 2. Containerization & Docker

## 🐳 Container Fundamentals

### Q4: What are containers and how do they differ from VMs?

**Answer:**

**Containers:**
- **Process-level isolation** using Linux namespaces and cgroups
- **Shared kernel** with host operating system
- **Lightweight**: Typically MB in size
- **Fast startup**: Seconds to start
- **Portable**: Same runtime environment everywhere

**Virtual Machines:**
- **Hardware-level virtualization** with hypervisor
- **Separate kernel** for each VM
- **Heavy**: GB in size due to full OS
- **Slow startup**: Minutes to boot
- **Isolation**: Complete OS isolation

**Comparison:**
```
Containers:
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│    App A    │ │    App B    │ │    App C    │
├─────────────┤ ├─────────────┤ ├─────────────┤
│  Libraries  │ │  Libraries  │ │  Libraries  │
└─────────────┴─┴─────────────┴─┴─────────────┘
┌─────────────────────────────────────────────┐
│            Container Runtime                │
├─────────────────────────────────────────────┤
│              Host OS                        │
└─────────────────────────────────────────────┘

Virtual Machines:
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│    App A    │ │    App B    │ │    App C    │
├─────────────┤ ├─────────────┤ ├─────────────┤
│  Guest OS   │ │  Guest OS   │ │  Guest OS   │
└─────────────┴─┴─────────────┴─┴─────────────┘
┌─────────────────────────────────────────────┐
│              Hypervisor                     │
├─────────────────────────────────────────────┤
│              Host OS                        │
└─────────────────────────────────────────────┘
```

---

### Q5: What is containerd and why did we choose it over Docker?

**Answer:**

**containerd:**
- **Industry standard**: OCI-compliant container runtime
- **Kubernetes native**: Default runtime since K8s 1.20
- **Lightweight**: Minimal resource overhead
- **Production-ready**: Used by major cloud providers
- **Graduated CNCF**: Mature, stable project

**Why containerd over Docker:**
1. **Simplicity**: Focused on container runtime only
2. **Performance**: Lower resource usage and faster startup
3. **Kubernetes Integration**: Better compatibility with K8s
4. **Security**: Smaller attack surface
5. **Standards Compliance**: Full OCI support

**Architecture:**
```
Container Stack:
┌─────────────────┐
│   Application   │
├─────────────────┤
│   Container     │
├─────────────────┤
│   containerd    │ ← High-level runtime
├─────────────────┤
│     runc        │ ← Low-level runtime
├─────────────────┤
│  Linux Kernel   │
└─────────────────┘
```

**Configuration in our setup:**
```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true  # Uses systemd for cgroup management
```

---

### Q6: Explain the container image layers and how they work.

**Answer:**

**Image Layers:**
- **Read-only layers**: Each Dockerfile instruction creates a layer
- **Copy-on-Write**: Changes create new layers, don't modify existing
- **Sharing**: Common layers shared between containers
- **Caching**: Speeds up builds and reduces storage

**Example Dockerfile:**
```dockerfile
FROM ubuntu:20.04           # Layer 1 (Base OS)
RUN apt-get update         # Layer 2 (Package update)
RUN apt-get install nginx  # Layer 3 (Nginx installation)
COPY app.conf /etc/nginx/  # Layer 4 (Config file)
EXPOSE 80                  # Metadata (no layer)
CMD ["nginx", "-g", "daemon off;"]  # Metadata
```

**Layer Structure:**
```
Container:
┌─────────────────┐ ← Read-Write Layer (Container changes)
├─────────────────┤ ← Layer 4: app.conf
├─────────────────┤ ← Layer 3: nginx install
├─────────────────┤ ← Layer 2: apt update
└─────────────────┘ ← Layer 1: ubuntu:20.04
```

**Benefits:**
- **Efficiency**: Multiple containers share base layers
- **Speed**: Only changed layers need to be pulled/pushed
- **Storage**: Reduced disk usage through layer sharing

---

# 3. Kubernetes Core Concepts

## ☸️ Architecture Questions

### Q7: Explain Kubernetes architecture and components.

**Answer:**

**Control Plane Components:**

**API Server (kube-apiserver):**
- **Entry point**: All cluster interactions go through API server
- **Authentication**: Verifies user identity
- **Authorization**: Checks user permissions
- **Admission Control**: Validates and mutates requests
- **etcd Communication**: Only component that talks to etcd

**etcd:**
- **Distributed database**: Stores all cluster state
- **Consistency**: Uses Raft consensus algorithm
- **Data**: Pods, services, secrets, configurations
- **Backup Critical**: Losing etcd means losing cluster

**Scheduler (kube-scheduler):**
- **Pod placement**: Decides which node runs each pod
- **Two-phase**: Filtering (feasible nodes) + Scoring (best node)
- **Factors**: Resource requirements, node capacity, affinity rules
- **Pluggable**: Custom schedulers can be implemented

**Controller Manager:**
- **Desired State**: Ensures current state matches desired state
- **Controllers**: Node, Replication, Endpoints, Service Account
- **Watch Pattern**: Monitors API server for changes
- **Reconciliation**: Takes action to fix discrepancies

**Worker Node Components:**

**kubelet:**
- **Node agent**: Manages pods on the node
- **Pod lifecycle**: Starts, stops, monitors containers
- **Health checks**: Liveness and readiness probes
- **Resource reporting**: Node capacity and usage to API server

**kube-proxy:**
- **Network proxy**: Implements Service abstraction
- **Load balancing**: Distributes traffic to pod endpoints
- **Modes**: iptables (default), IPVS, userspace
- **Service discovery**: Updates routing rules

**Container Runtime:**
- **Container management**: Pulls images, runs containers
- **CRI interface**: Container Runtime Interface
- **Examples**: containerd, CRI-O, Docker (deprecated)

---

### Q8: What are Pods and why are they the smallest deployable unit?

**Answer:**

**Pod Definition:**
- **Co-located containers**: One or more containers that share:
  - Network namespace (same IP address)
  - Storage volumes
  - Lifecycle (start/stop together)

**Why Pods, not individual containers:**

1. **Tight coupling**: Some applications need helper containers
2. **Shared resources**: Network and storage sharing
3. **Atomic deployment**: All containers in pod deployed together
4. **Scaling unit**: Scale entire pod, not individual containers

**Common Pod Patterns:**

**Sidecar Pattern:**
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: web-server
    image: nginx
  - name: log-shipper    # Sidecar container
    image: filebeat
    volumeMounts:
    - name: logs
      mountPath: /var/log
```

**Ambassador Pattern:**
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: my-app
  - name: proxy         # Ambassador container
    image: ambassador
    ports:
    - containerPort: 8080
```

**Adapter Pattern:**
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: legacy-app
    image: legacy
  - name: adapter       # Adapter container
    image: format-converter
```

**Pod Lifecycle:**
```
Pending → Running → Succeeded/Failed → (Termination)
```

---

### Q9: Explain the difference between Deployments, ReplicaSets, and StatefulSets.

**Answer:**

**ReplicaSet:**
- **Basic replication**: Ensures specified number of pod replicas
- **Pod template**: Defines pod specification
- **Label selector**: Identifies pods it manages
- **Limited functionality**: No update strategy

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replica
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

**Deployment:**
- **Higher-level abstraction**: Manages ReplicaSets
- **Rolling updates**: Zero-downtime deployments
- **Rollback capability**: Can revert to previous versions
- **Declarative updates**: Describe desired state

**Update Strategies:**
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1      # Max pods down during update
      maxSurge: 1           # Max extra pods during update
```

**StatefulSet:**
- **Stateful applications**: Databases, clustered applications
- **Stable identity**: Predictable pod names (web-0, web-1, web-2)
- **Ordered deployment**: Pods created in sequence
- **Persistent storage**: Each pod gets own PVC

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  template:
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

**Use Cases:**
- **Deployment**: Stateless apps (web servers, APIs)
- **StatefulSet**: Databases, message queues, clustered apps
- **DaemonSet**: Node agents (monitoring, logging)
- **Job**: Batch processing, one-time tasks
- **CronJob**: Scheduled tasks

---

### Q10: How do Services work in Kubernetes?

**Answer:**

**Service Purpose:**
- **Stable endpoint**: Pods come and go, services provide consistent access
- **Load balancing**: Distributes traffic across pod replicas
- **Service discovery**: DNS-based service resolution

**Service Types:**

**ClusterIP (Default):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```
- **Internal only**: Accessible within cluster
- **DNS name**: my-service.default.svc.cluster.local
- **Use case**: Internal communication

**NodePort:**
```yaml
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```
- **External access**: Via any node's IP
- **Port range**: 30000-32767
- **Use case**: Development, testing

**LoadBalancer:**
```yaml
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
```
- **Cloud integration**: Creates cloud load balancer
- **External IP**: Assigned by cloud provider
- **Use case**: Production external services

**ExternalName:**
```yaml
spec:
  type: ExternalName
  externalName: api.example.com
```
- **DNS alias**: Maps service name to external DNS
- **No proxying**: Direct DNS resolution
- **Use case**: External service abstraction

**How Services Work:**
```
Client Request → Service (Virtual IP) → Endpoints → Pod IPs
```

**kube-proxy Implementation:**
1. **Watches API**: Monitors service and endpoint changes
2. **Updates rules**: Configures iptables/IPVS rules
3. **Load balancing**: Routes traffic to healthy pods

---

# 4. Kubernetes Networking

## 🌐 Networking Deep Dive

### Q11: Explain the Kubernetes networking model and CNI.

**Answer:**

**Kubernetes Networking Requirements:**
1. **Container-to-container**: Within pod (localhost)
2. **Pod-to-pod**: Across nodes (direct communication)
3. **Pod-to-service**: Service discovery and load balancing
4. **External-to-service**: Ingress traffic

**CNI (Container Network Interface):**
- **Standard**: Defines how container runtimes configure networking
- **Plugins**: Different implementations (Flannel, Calico, Weave)
- **Responsibilities**: IP allocation, routing, network policies

**Our Setup - Flannel:**
```yaml
Network Architecture:
├── Physical Network: 10.0.0.0/16 (VPC)
├── Pod Network: 10.244.0.0/16 (Flannel)
│   ├── Node1: 10.244.0.0/24
│   ├── Node2: 10.244.1.0/24
│   └── Node3: 10.244.2.0/24
└── Service Network: 10.96.0.0/16 (ClusterIP)
```

**Flannel Implementation:**
- **Overlay network**: VXLAN encapsulation
- **Backend types**: VXLAN, host-gw, UDP
- **Simplicity**: Easy to deploy and manage

**Packet Flow Example:**
```
Pod A (10.244.1.2) on Node1 → Pod B (10.244.2.3) on Node2

1. Pod A sends packet to 10.244.2.3
2. Node1 routing table: 10.244.2.0/24 via flannel.1
3. Flannel encapsulates packet in VXLAN
4. Physical network routes VXLAN packet to Node2
5. Node2 Flannel decapsulates packet
6. Packet delivered to Pod B
```

---

### Q12: How does service discovery work in Kubernetes?

**Answer:**

**DNS-based Service Discovery:**

Kubernetes runs CoreDNS cluster add-on that provides:
- **Service records**: my-service.namespace.svc.cluster.local
- **Pod records**: pod-ip.namespace.pod.cluster.local
- **Search domains**: Automatic domain completion

**Service DNS Records:**
```
Service: nginx-service in default namespace
├── A Record: nginx-service.default.svc.cluster.local → ClusterIP
├── SRV Record: Port information
└── Short names: nginx-service (within same namespace)
```

**Example Resolution:**
```bash
# From within cluster
nslookup nginx-service
# Returns: 10.96.123.45 (ClusterIP)

# Full FQDN
nslookup nginx-service.default.svc.cluster.local
# Returns: 10.96.123.45
```

**Environment Variables (Legacy):**
```bash
NGINX_SERVICE_HOST=10.96.123.45
NGINX_SERVICE_PORT=80
NGINX_SERVICE_PORT_HTTP=80
```

**Service Discovery Methods:**
1. **DNS (Preferred)**: Automatic, no configuration needed
2. **Environment variables**: Legacy, requires pod restart
3. **API**: Direct API server queries (rare)

**CoreDNS Configuration:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        forward . /etc/resolv.conf
    }
```

---

### Q13: What are Network Policies and how do they work?

**Answer:**

**Network Policies:**
- **Firewall rules**: Control traffic between pods
- **Default behavior**: All traffic allowed
- **CNI support**: Requires CNI that supports policies (Calico, Cilium)

**Types of Policies:**
1. **Ingress**: Traffic coming to selected pods
2. **Egress**: Traffic leaving from selected pods

**Example Policy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-deny-all
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - podSelector:
        matchLabels:
          role: api
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 3306
```

**Policy Behavior:**
- **Additive**: Multiple policies combine (union)
- **Default deny**: Empty policy denies all traffic
- **Namespace isolation**: Can isolate entire namespaces

**Common Patterns:**

**Deny All Traffic:**
```yaml
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**Allow from Same Namespace:**
```yaml
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: production
```

**Note**: Our Flannel setup doesn't support Network Policies. Would need Calico or Cilium for enforcement.

---

# 5. Configuration Management (Ansible)

## 🔧 Ansible Deep Dive

### Q14: Why did we choose Ansible over other configuration management tools?

**Answer:**

**Ansible Advantages:**

**Agentless:**
- **SSH-based**: No agents to install or maintain
- **Push model**: Control from central location
- **Reduced overhead**: No daemon processes on managed nodes

**Simplicity:**
- **YAML syntax**: Human-readable, easy to learn
- **Declarative**: Describe desired state, not steps
- **No programming**: Playbooks are configuration, not code

**Idempotency:**
- **Safe to re-run**: Can execute multiple times safely
- **State checking**: Only makes changes when needed
- **Predictable**: Same result every time

**Comparison with alternatives:**

| Tool | Agent | Language | Learning Curve | Push/Pull |
|------|--------|----------|----------------|-----------|
| Ansible | No | YAML | Low | Push |
| Chef | Yes | Ruby | High | Pull |
| Puppet | Yes | Ruby DSL | High | Pull |
| Salt | Yes | YAML/Python | Medium | Both |

**Our Use Case:**
```yaml
Infrastructure Automation:
├── Server provisioning (post-terraform)
├── Package installation
├── Service configuration
├── Application deployment
└── Kubernetes cluster setup
```

---

### Q15: Explain Ansible playbooks, roles, and best practices.

**Answer:**

**Playbook Structure:**
```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    max_clients: 200
  tasks:
    - name: Install Apache
      apt:
        name: apache2
        state: present
    - name: Start Apache
      service:
        name: apache2
        state: started
        enabled: yes
      notify: restart apache
  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
```

**Key Components:**

**Tasks:**
- **Atomic operations**: Single unit of work
- **Modules**: Reusable code (apt, service, copy)
- **Idempotency**: Check before change

**Variables:**
```yaml
# Group vars
webservers:
  vars:
    http_port: 80

# Host vars
web1.example.com:
  mysql_root_password: secret
```

**Handlers:**
- **Event-driven**: Only run when notified
- **End of play**: Run after all tasks complete
- **Use cases**: Restart services, reload configs

**Conditionals:**
```yaml
- name: Install package
  apt:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"
```

**Loops:**
```yaml
- name: Create users
  user:
    name: "{{ item }}"
    state: present
  loop:
    - alice
    - bob
    - charlie
```

**Roles:**
```
roles/
└── webserver/
    ├── tasks/main.yml
    ├── handlers/main.yml
    ├── templates/
    ├── files/
    ├── vars/main.yml
    └── defaults/main.yml
```

**Best Practices:**

1. **Use roles**: Reusable, organized code
2. **Vault for secrets**: Encrypt sensitive data
3. **Inventory groups**: Logical organization
4. **Limit scope**: Use --limit for safety
5. **Check mode**: Test before applying
6. **Tags**: Selective execution

---

### Q16: How did you handle the Kubernetes setup with Ansible?

**Answer:**

**Our Ansible Structure:**
```
ansible/
├── inventory.ini           # Host definitions
├── k8s-playbook-common.yml # Common setup (all nodes)
├── k8s-master.yml         # Master node initialization
├── k8s-worker.yml         # Worker node joining
└── k8s-monitoring.yml     # Monitoring stack
```

**Inventory Configuration:**
```ini
[all]
13.201.18.248 ansible_user=ubuntu
13.127.102.234 ansible_user=ubuntu
35.154.146.24 ansible_user=ubuntu

[controlplane]
13.201.18.248

[workers]
13.127.102.234
35.154.146.24
```

**Common Setup Tasks:**
```yaml
Tasks in k8s-playbook-common.yml:
├── Update package cache
├── Install dependencies (curl, ca-certificates)
├── Install containerd
├── Configure containerd (SystemdCgroup = true)
├── Load kernel modules (br_netfilter, overlay)
├── Set sysctl parameters for networking
├── Add Kubernetes repository
├── Install kubelet, kubeadm, kubectl
└── Hold package versions
```

**Key Challenges Solved:**

**1. Kubernetes Repository Update:**
```yaml
# Old (deprecated)
repo: "https://apt.kubernetes.io/ kubernetes-xenial main"

# New (current)
repo: "https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /"
```

**2. Package Holding:**
```yaml
# Fixed: Use dpkg_selections instead of mark_hold
- name: Hold kube packages
  dpkg_selections:
    name: "{{ item }}"
    selection: hold
  loop:
    - kubelet
    - kubeadm
    - kubectl
```

**3. Dynamic Join Command:**
```yaml
# Generate on master
- name: Generate join command
  shell: kubeadm token create --print-join-command
  register: join_command

# Use on workers
- name: Join cluster
  command: "{{ join_command.stdout }}"
```

**4. Monitoring Stack:**
```yaml
- name: Install Helm
  shell: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

- name: Add Prometheus repo
  shell: helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

- name: Install monitoring
  shell: helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

**Benefits Achieved:**
- **Idempotent**: Can re-run safely
- **Consistent**: Same setup across environments
- **Version controlled**: Infrastructure as code
- **Auditable**: All changes tracked

---

# 6. Monitoring & Observability

## 📊 Prometheus & Grafana

### Q17: Explain the Prometheus architecture and data model.

**Answer:**

**Prometheus Architecture:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Prometheus     │    │  Alertmanager   │    │   Grafana       │
│  Server         │───▶│                 │    │                 │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Node Exporter  │    │  Application    │    │  Pushgateway    │
│                 │    │  /metrics       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Core Components:**

**Prometheus Server:**
- **Time-series DB**: Stores metrics with timestamps
- **Scraping**: Pulls metrics from targets (HTTP GET /metrics)
- **Storage**: Local disk storage (TSDB)
- **Query Engine**: PromQL processor
- **Web UI**: Built-in visualization

**Data Model:**
```
Metric Sample:
├── Metric Name: http_requests_total
├── Labels: {method="GET", status="200", handler="/api/users"}
├── Timestamp: 1634567890
└── Value: 1047
```

**Metric Types:**

**Counter:**
- **Monotonically increasing**: Only goes up
- **Examples**: Request count, error count
- **Operations**: rate(), increase()
```promql
rate(http_requests_total[5m])  # Requests per second
```

**Gauge:**
- **Can go up/down**: Current value
- **Examples**: CPU usage, memory usage, queue length
```promql
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes
```

**Histogram:**
- **Buckets**: Distribution of values
- **Automatic**: _count, _sum, _bucket metrics
- **Use case**: Request latency, response size
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

**Summary:**
- **Client-side quantiles**: Pre-calculated percentiles
- **Not aggregatable**: Can't combine across instances

**Scraping Configuration:**
```yaml
scrape_configs:
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
    - role: node
    relabel_configs:
    - source_labels: [__address__]
      regex: '(.*):10250'
      target_label: __address__
      replacement: '${1}:9100'
```

---

### Q18: How does service discovery work in Prometheus?

**Answer:**

**Service Discovery Mechanisms:**

**Static Configuration:**
```yaml
scrape_configs:
  - job_name: 'static-targets'
    static_configs:
    - targets: ['localhost:9090', 'node1:9100']
```

**Kubernetes Service Discovery:**
```yaml
scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
      action: replace
      target_label: __metrics_path__
      regex: (.+)
```

**Our Setup - ServiceMonitors:**
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: prometheus-node-exporter
  endpoints:
  - port: http-metrics
    interval: 30s
    path: /metrics
```

**How ServiceMonitors Work:**
1. **Prometheus Operator**: Watches for ServiceMonitor objects
2. **Service Discovery**: Finds services matching selector
3. **Target Generation**: Creates scrape targets
4. **Configuration**: Updates Prometheus scrape config
5. **Scraping**: Prometheus pulls metrics from endpoints

**Target Discovery Process:**
```
ServiceMonitor → Service → Endpoints → Pod IPs → Metrics
```

**Benefits:**
- **Dynamic**: Automatically discovers new targets
- **Scalable**: No manual configuration for each target
- **Kubernetes-native**: Uses K8s labels and selectors
- **Declarative**: Describe what to monitor, not how

**Common Service Discovery Types:**
- **kubernetes_sd_configs**: Kubernetes API
- **consul_sd_configs**: Consul service registry  
- **ec2_sd_configs**: AWS EC2 instances
- **file_sd_configs**: File-based discovery
- **dns_sd_configs**: DNS SRV records

---

### Q19: What metrics are you collecting and why?

**Answer:**

**Infrastructure Metrics (Node Exporter):**

**System Metrics:**
```promql
# CPU Usage
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk Usage
(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100

# Network Traffic
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

**Kubernetes Metrics (kube-state-metrics):**

**Pod Metrics:**
```promql
# Pod Status
kube_pod_status_phase{phase="Running"}

# Container Restarts
rate(kube_pod_container_status_restarts_total[5m])

# Resource Usage
container_cpu_usage_seconds_total
container_memory_working_set_bytes
```

**Deployment Metrics:**
```promql
# Available Replicas
kube_deployment_status_replicas_available

# Desired vs Available
kube_deployment_spec_replicas - kube_deployment_status_replicas_available
```

**Application Metrics:**

**Golden Signals:**
1. **Latency**: How long requests take
2. **Traffic**: How many requests per second
3. **Errors**: Rate of failed requests
4. **Saturation**: How "full" the service is

```promql
# Request Rate (Traffic)
rate(http_requests_total[5m])

# Error Rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Response Time (Latency)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Saturation (CPU/Memory)
avg by(pod) (rate(container_cpu_usage_seconds_total[5m]))
```

**Custom Metrics Examples:**
```promql
# Queue Depth
queue_size{queue="processing"}

# Cache Hit Rate
cache_hits_total / (cache_hits_total + cache_misses_total)

# Database Connections
database_connections_active
```

**Why These Metrics:**
- **Proactive monitoring**: Detect issues before users notice
- **Capacity planning**: Understand resource trends
- **SLA/SLO tracking**: Measure service performance
- **Troubleshooting**: Root cause analysis during incidents

---

### Q20: Explain alerting strategy and best practices.

**Answer:**

**Alert Lifecycle:**
```
Metric Collection → Rule Evaluation → Alert Firing → Notification → Resolution
```

**Alerting Rules:**
```yaml
groups:
- name: node-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
      team: platform
    annotations:
      summary: "High CPU usage on {{ $labels.instance }}"
      description: "CPU usage is {{ $value }}% for more than 5 minutes"
      
  - alert: NodeDown
    expr: up{job="node-exporter"} == 0
    for: 1m
    labels:
      severity: critical
      team: platform
    annotations:
      summary: "Node {{ $labels.instance }} is down"
      runbook: "https://wiki.company.com/runbooks/node-down"
```

**Alert Severity Levels:**

**Critical:**
- **User-facing impact**: Service degradation/outage
- **Immediate response**: Page on-call engineer
- **Examples**: Service down, data loss, security breach

**Warning:**
- **Potential impact**: May lead to critical if not addressed
- **Business hours response**: Create ticket, investigate
- **Examples**: High resource usage, failed jobs

**Info:**
- **FYI notifications**: Good to know, no action needed
- **Documentation**: Changes, deployments, scaling events

**Alertmanager Configuration:**
```yaml
global:
  smtp_smarthost: 'localhost:587'
  
route:
  group_by: ['alertname', 'cluster']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'default'
  routes:
  - match:
      severity: critical
    receiver: 'pager'
  - match:
      team: database
    receiver: 'dba-team'

receivers:
- name: 'default'
  email_configs:
  - to: 'team@company.com'
    subject: '[{{ .Status | toUpper }}] {{ .GroupLabels.alertname }}'
    
- name: 'pager'
  pagerduty_configs:
  - service_key: 'abc123'
```

**Best Practices:**

**Alert Design:**
1. **Actionable**: Every alert needs clear action
2. **Meaningful**: Avoid alert fatigue
3. **Contextual**: Include relevant information
4. **Runbooks**: Document response procedures

**Grouping and Routing:**
```yaml
# Group related alerts
group_by: ['alertname', 'cluster', 'service']

# Route by team/severity
routes:
  - match:
      team: frontend
    receiver: frontend-team
  - match_re:
      alertname: ^Database.*
    receiver: dba-team
```

**Inhibition Rules:**
```yaml
inhibit_rules:
- source_match:
    alertname: 'NodeDown'
  target_match:
    alertname: 'HighCPUUsage'
  equal: ['instance']
```

**Common Anti-patterns:**
- **Too many alerts**: Causes alert fatigue
- **Vague messages**: "Something is wrong"
- **No runbooks**: People don't know what to do
- **Wrong severity**: Critical alerts for non-critical issues

---

# 7. Security & Best Practices

## 🔒 Security Questions

### Q21: How do you secure a Kubernetes cluster?

**Answer:**

**Cluster Security Layers:**

**API Server Security:**
```yaml
# Authentication
authentication:
  - x509:           # Client certificates
  - webhook:        # External auth provider
  - serviceAccount: # Service account tokens

# Authorization  
authorization:
  - rbac:           # Role-based access control
  - webhook:        # External authorization
  - node:           # Node authorization
```

**RBAC (Role-Based Access Control):**
```yaml
# Role definition
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

---
# Role binding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Network Security:**
```yaml
# Network Policy - Deny all traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**Pod Security:**
```yaml
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

**Secret Management:**
```yaml
# Sealed Secrets (GitOps-friendly)
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: my-secret
spec:
  encryptedData:
    password: AgBy3i4OJSWK+PiTySYZZA9rO43cGDEQAx...

# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.company.com"
      path: "secret"
      version: "v2"
```

**Additional Security Measures:**

**Admission Controllers:**
- **PodSecurityPolicy**: Pod security standards
- **OPA Gatekeeper**: Policy as code
- **Falco**: Runtime security monitoring

**Image Security:**
```yaml
# Image scanning in CI/CD
steps:
  - name: Scan image
    run: |
      trivy image myapp:latest
      
# Admission controller for images
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: myregistry.com/myapp:v1.2.3  # Signed image
    imagePullPolicy: Always
```

**Cluster Hardening:**
- **Disable default service accounts**
- **Enable audit logging**
- **Separate etcd network**
- **Regular security updates**
- **Node-level security** (CIS benchmarks)

---

### Q22: What are Kubernetes secrets and how do you manage them securely?

**Answer:**

**Kubernetes Secrets:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=     # base64 encoded
  password: MWYyZDFlMmU=  # base64 encoded
```

**Secret Types:**
- **Opaque**: Arbitrary user data
- **kubernetes.io/service-account-token**: Service account tokens
- **kubernetes.io/dockercfg**: Docker registry credentials
- **kubernetes.io/tls**: TLS certificates

**Using Secrets:**
```yaml
# Environment variables
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
          
# Volume mount
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
  volumes:
  - name: secret-volume
    secret:
      secretName: ssl-certs
```

**Security Concerns with Default Secrets:**
1. **Base64 encoding**: Not encryption, easily decoded
2. **etcd storage**: Stored in plain text in etcd
3. **API access**: Anyone with API access can read
4. **Pod access**: All containers in pod can access

**Better Secret Management:**

**Encrypted at Rest:**
```yaml
# etcd encryption configuration
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: <base64-encoded-32-byte-key>
  - identity: {}
```

**External Secret Management:**

**HashiCorp Vault Integration:**
```yaml
# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-secret
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: app-secret
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: secret/myapp
      property: password
```

**AWS Secrets Manager:**
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
```

**Sealed Secrets (GitOps):**
```bash
# Encrypt secret
echo -n mypassword | kubectl create secret generic mysecret --dry-run=client --from-file=password=/dev/stdin -o yaml | kubeseal -o yaml > sealed-secret.yaml

# Deploy encrypted secret
kubectl apply -f sealed-secret.yaml
```

**Best Practices:**
1. **External systems**: Use dedicated secret management tools
2. **Least privilege**: Limit secret access via RBAC
3. **Rotation**: Regularly rotate secrets
4. **Audit**: Log secret access and changes
5. **GitOps-friendly**: Use sealed secrets for version control

---

# 8. Troubleshooting Scenarios

## 🔍 Real-world Problems

### Q23: A pod is stuck in Pending state. How do you troubleshoot?

**Answer:**

**Systematic Troubleshooting Approach:**

**1. Check Pod Status:**
```bash
kubectl get pods -o wide
kubectl describe pod <pod-name>
```

**Common Pending Reasons:**

**Insufficient Resources:**
```yaml
# Pod Events
Events:
  Warning  FailedScheduling  pod  0/3 nodes are available: 3 Insufficient cpu.
```

**Solution:**
```bash
# Check node resources
kubectl top nodes
kubectl describe nodes

# Check resource requests
kubectl describe pod <pod-name> | grep -A 5 "Requests:"

# Options:
# 1. Reduce resource requests
# 2. Add more nodes
# 3. Remove resource requests (if appropriate)
```

**Node Selector Mismatch:**
```yaml
spec:
  nodeSelector:
    disktype: ssd  # No nodes have this label
```

**Solution:**
```bash
# Check node labels
kubectl get nodes --show-labels

# Fix options:
# 1. Add label to node: kubectl label nodes <node> disktype=ssd
# 2. Remove nodeSelector
# 3. Use correct label
```

**Taints and Tolerations:**
```yaml
# Node has taint, pod lacks toleration
Events:
  Warning  FailedScheduling  pod  0/3 nodes are available: 3 node(s) had taint {key: NoSchedule}
```

**Solution:**
```bash
# Check node taints
kubectl describe node <node-name> | grep Taints

# Add toleration to pod
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```

**Image Pull Issues:**
```yaml
Events:
  Warning  Failed  pod  Failed to pull image "nginx:wrongtag": repository does not exist
```

**Solution:**
```bash
# Check image availability
docker pull nginx:wrongtag

# Fix image reference
# Check imagePullSecrets if private registry
```

**PVC Binding Issues:**
```yaml
Events:
  Warning  FailedScheduling  pod  pod has unbound immediate PersistentVolumeClaims
```

**Solution:**
```bash
# Check PVC status
kubectl get pvc
kubectl describe pvc <pvc-name>

# Options:
# 1. Create matching PV
# 2. Use storage class with dynamic provisioning
# 3. Fix PVC specifications
```

**Troubleshooting Steps:**
1. **kubectl describe**: Most informative command
2. **Check events**: Recent cluster events
3. **Resource availability**: CPU, memory, storage
4. **Network connectivity**: Node-to-node, pod-to-pod
5. **RBAC permissions**: Service account permissions

---

### Q24: Application pods are running but not receiving traffic. How do you debug?

**Answer:**

**Service-to-Pod Connection Issues:**

**1. Verify Service Configuration:**
```bash
# Check service exists and has endpoints
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>
```

**Common Issues:**

**No Endpoints:**
```yaml
# Service selector doesn't match pod labels
Service Selector:
  app: nginx
  
Pod Labels:
  app: nginx-server  # Mismatch!
```

**Solution:**
```bash
# Check pod labels
kubectl get pods --show-labels

# Fix service selector or pod labels
kubectl patch service <svc> -p '{"spec":{"selector":{"app":"nginx-server"}}}'
```

**2. Test Service Connectivity:**
```bash
# Test from within cluster
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh

# Inside test pod:
nslookup <service-name>
wget -qO- http://<service-name>:<port>
telnet <service-ip> <port>
```

**3. Check Pod Readiness:**
```bash
kubectl get pods -o wide
kubectl describe pod <pod-name>
```

**Readiness Probe Failing:**
```yaml
Events:
  Warning  Unhealthy  pod  Readiness probe failed: Get http://10.244.1.5:8080/health: connection refused
```

**Solution:**
```yaml
# Fix readiness probe
spec:
  containers:
  - name: app
    readinessProbe:
      httpGet:
        path: /health      # Correct endpoint
        port: 8080         # Correct port
      initialDelaySeconds: 30
      periodSeconds: 10
```

**4. Network Policy Issues:**
```bash
# Check for network policies
kubectl get networkpolicies -A

# Test without network policies (if safe)
kubectl delete networkpolicy <policy-name>
```

**5. Debug Service Mesh (if using):**
```bash
# Istio example
kubectl get virtualservices
kubectl get destinationrules

# Check sidecar proxy
kubectl logs <pod-name> -c istio-proxy
```

**6. Check kube-proxy:**
```bash
# On nodes
sudo iptables -t nat -L | grep <service-name>

# Check kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy
```

**Step-by-step Debug Process:**
```
1. Service exists? → kubectl get svc
2. Endpoints exist? → kubectl get endpoints
3. Pod labels match? → kubectl get pods --show-labels
4. Pod ready? → kubectl get pods
5. Service reachable? → Test from within cluster
6. Application healthy? → Check app logs
7. Network policies? → kubectl get networkpolicies
```

---

### Q25: How would you troubleshoot high resource usage in the cluster?

**Answer:**

**Resource Investigation Workflow:**

**1. Identify High Usage:**
```bash
# Node-level resource usage
kubectl top nodes

# Pod-level resource usage
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory

# Specific namespace
kubectl top pods -n <namespace>
```

**2. Deep Dive Analysis:**

**CPU Analysis:**
```bash
# Find CPU-hungry pods
kubectl top pods -A --sort-by=cpu | head -20

# Check resource requests vs limits
kubectl describe pod <pod-name> | grep -A 10 "Requests:"

# Historical data (if metrics-server available)
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods" | jq '.items[] | select(.containers[].usage.cpu | tonumber > 100000000) | .metadata.name'
```

**Memory Analysis:**
```bash
# Memory usage per pod
kubectl top pods -A --sort-by=memory

# Check for memory leaks
kubectl logs <pod-name> --previous

# OOMKilled events
kubectl get events --field-selector reason=OOMKilling
```

**3. Resource Limit Analysis:**
```bash
# Pods without resource limits
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources.limits}{"\n"}{end}' | grep -v "cpu\|memory"

# QoS classes
kubectl get pods -A -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

**4. Container-level Investigation:**

**Using Prometheus/Grafana:**
```promql
# Top CPU consuming containers
topk(10, rate(container_cpu_usage_seconds_total[5m]))

# Memory usage by container
topk(10, container_memory_working_set_bytes / 1024 / 1024)

# Containers without limits
count by (pod_name, container_name) (container_spec_cpu_quota == -1)
```

**5. Application-specific Debugging:**

**Java Applications:**
```bash
# Heap dump
kubectl exec <pod-name> -- jstack <pid>
kubectl exec <pod-name> -- jstat -gc <pid>

# Application metrics
curl http://<pod-ip>:8080/actuator/metrics/jvm.memory.used
```

**Node.js Applications:**
```bash
# Memory usage
kubectl exec <pod-name> -- node -e "console.log(process.memoryUsage())"

# CPU profiling (if enabled)
kubectl port-forward <pod-name> 9229:9229
```

**6. Remediation Strategies:**

**Immediate Actions:**
```bash
# Scale down high-usage pods
kubectl scale deployment <deployment> --replicas=2

# Add resource limits
kubectl patch deployment <deployment> -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"limits":{"cpu":"500m","memory":"512Mi"}}}]}}}}'

# Restart problematic pods
kubectl delete pod <pod-name>
```

**Long-term Solutions:**
```yaml
# Proper resource configuration
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Monitoring Setup:**
```yaml
# Resource quotas per namespace
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "4Gi"
    limits.cpu: "4"
    limits.memory: "8Gi"
```

---

# 9. System Design Questions

## 🏗️ Architecture & Design

### Q26: Design a CI/CD pipeline for Kubernetes applications.

**Answer:**

**Complete CI/CD Architecture:**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │    │   Build     │    │   Test      │    │   Deploy    │
│   Control   │───▶│   Stage     │───▶│   Stage     │───▶│   Stage     │
│   (Git)     │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                   │                   │
                          ▼                   ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                   │   Docker    │    │   Security  │    │ Kubernetes  │
                   │   Registry  │    │   Scan      │    │  Cluster    │
                   └─────────────┘    └─────────────┘    └─────────────┘
```

**Pipeline Stages:**

**1. Source Control (Git):**
```yaml
# .gitops/ structure
├── applications/
│   ├── app-name/
│   │   ├── base/
│   │   │   ├── kustomization.yaml
│   │   │   ├── deployment.yaml
│   │   │   └── service.yaml
│   │   └── overlays/
│   │       ├── staging/
│   │       └── production/
└── infrastructure/
    ├── terraform/
    └── ansible/
```

**2. Build Stage (GitLab CI/GitHub Actions):**
```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - security
  - deploy

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
    - develop

test:
  stage: test
  script:
    - docker run --rm $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA npm test
    - docker run --rm $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA npm run lint

security-scan:
  stage: security
  script:
    - trivy image $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - clair-scanner $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  allow_failure: false

deploy-staging:
  stage: deploy
  script:
    - helm upgrade --install myapp ./helm/myapp 
      --set image.tag=$CI_COMMIT_SHA 
      --namespace staging
  environment:
    name: staging
  only:
    - develop
```

**3. GitOps Deployment:**
```yaml
# ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
spec:
  project: default
  source:
    repoURL: https://gitlab.com/company/k8s-configs
    targetRevision: HEAD
    path: applications/myapp/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**4. Helm Charts Structure:**
```yaml
# helm/myapp/values.yaml
replicaCount: 3
image:
  repository: registry.company.com/myapp
  tag: latest
  pullPolicy: IfNotPresent

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: api.company.com
      paths:
        - path: /
          pathType: Prefix
```

**5. Multi-Environment Strategy:**
```yaml
# environments/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
patchesStrategicMerge:
  - replica-count.yaml
images:
  - name: myapp
    newTag: staging-latest

# environments/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
patchesStrategicMerge:
  - replica-count.yaml
  - resource-limits.yaml
images:
  - name: myapp
    newTag: v1.2.3
```

**Quality Gates:**
```yaml
# Automated quality checks
quality_gates:
  - unit_tests: >90% coverage
  - integration_tests: all passing
  - security_scan: no critical vulnerabilities
  - performance_test: <200ms p95 latency
  - smoke_tests: all endpoints healthy
```

**Deployment Strategies:**

**Blue-Green:**
```yaml
# Blue environment (current)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
spec:
  replicas: 3

# Green environment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3

# Traffic switching
apiVersion: v1
kind: Service
spec:
  selector:
    app: myapp
    version: green  # Switch traffic
```

**Canary Deployment:**
```yaml
# Istio VirtualService
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
spec:
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: myapp
        subset: v2
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10  # 10% canary traffic
```

**Monitoring Integration:**
```yaml
# Deployment success criteria
success_criteria:
  - error_rate: <1%
  - response_time: <500ms
  - deployment_time: <10min
  - rollback_capability: automated
```

---

### Q27: How would you design a multi-tenant Kubernetes platform?

**Answer:**

**Multi-Tenancy Models:**

**1. Namespace-based (Soft Multi-tenancy):**
```yaml
# Tenant namespace
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-a
  labels:
    tenant: tenant-a
    tier: gold

---
# Resource Quota
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-a-quota
  namespace: tenant-a
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "8Gi"
    limits.cpu: "8"
    limits.memory: "16Gi"
    persistentvolumeclaims: "10"
    pods: "50"

---
# Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-isolation
  namespace: tenant-a
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
```

**2. RBAC Per Tenant:**
```yaml
# Tenant admin role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: tenant-a
  name: tenant-admin
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps", "extensions"]
  resources: ["*"]
  verbs: ["*"]

---
# Role binding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant-a-admin
  namespace: tenant-a
subjects:
- kind: User
  name: tenant-a-admin@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: tenant-admin
  apiGroup: rbac.authorization.k8s.io
```

**3. Virtual Clusters (Hard Multi-tenancy):**
```yaml
# vcluster configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: vcluster-config
data:
  config.yaml: |
    vcluster:
      image: rancher/k3s:v1.21.3-k3s1
    rbac:
      clusterRole:
        create: true
    storage:
      persistence: true
      size: 5Gi
    ingress:
      enabled: true
      host: tenant-a.k8s.company.com
```

**Platform Components:**

**1. Control Plane:**
```yaml
# Platform operator
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tenant-operator
spec:
  template:
    spec:
      containers:
      - name: operator
        image: company/tenant-operator:v1.0.0
        env:
        - name: WEBHOOK_ENABLED
          value: "true"
        - name: MONITORING_ENABLED  
          value: "true"
```

**2. Self-Service Portal:**
```yaml
# Web interface for tenants
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tenant-portal
spec:
  template:
    spec:
      containers:
      - name: portal
        image: company/tenant-portal:v1.0.0
        env:
        - name: KUBERNETES_SERVICE_HOST
          value: kubernetes.default.svc
        - name: RBAC_ENABLED
          value: "true"
```

**3. Resource Governance:**
```yaml
# Policy as Code (OPA Gatekeeper)
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }

---
# Constraint
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: must-have-tenant
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    labels: ["tenant", "cost-center"]
```

**4. Monitoring Per Tenant:**
```yaml
# Tenant-specific ServiceMonitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: tenant-a-apps
  namespace: tenant-a
spec:
  selector:
    matchLabels:
      tenant: tenant-a
  endpoints:
  - port: metrics

---
# Tenant dashboard access
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-tenant-config
data:
  datasource.yaml: |
    apiVersion: 1
    datasources:
    - name: Tenant-A-Prometheus
      type: prometheus
      url: http://prometheus:9090
      jsonData:
        httpHeaderName1: "X-Tenant-Filter"
      secureJsonData:
        httpHeaderValue1: "tenant-a"
```

**5. Cost Management:**
```yaml
# Resource tracking
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-allocation
data:
  config.yaml: |
    tenants:
      tenant-a:
        cost_center: "12345"
        billing_contact: "finance@tenant-a.com"
        resource_limits:
          cpu_hours_monthly: 1000
          storage_gb_monthly: 500
```

**Security Considerations:**

**Pod Security Standards:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-a
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

**Image Security:**
```yaml
# Admission webhook for image scanning
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: image-security-webhook
webhooks:
- name: image-scan.company.com
  clientConfig:
    service:
      name: image-scanner
      namespace: platform
      path: "/scan"
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
```

**Tenant Isolation Levels:**
1. **Namespace-level**: Good for trusted tenants
2. **Node-level**: Dedicated nodes per tenant
3. **Cluster-level**: Separate clusters (highest isolation)

**Platform Benefits:**
- **Self-service**: Tenants manage their own resources
- **Cost allocation**: Track usage per tenant
- **Governance**: Consistent policies across tenants
- **Scalability**: Add tenants without manual setup

---

### Q28: Design a disaster recovery strategy for Kubernetes.

**Answer:**

**Disaster Recovery Architecture:**

```
Primary Cluster (Region A)          Disaster Recovery (Region B)
┌─────────────────────────┐        ┌─────────────────────────┐
│  ┌─────┐ ┌─────────────┐ │        │  ┌─────┐ ┌─────────────┐ │
│  │etcd │ │Application  │ │   ───▶ │  │etcd │ │Application  │ │
│  │     │ │   Pods      │ │        │  │     │ │   Pods      │ │
│  └─────┘ └─────────────┘ │        │  └─────┘ └─────────────┘ │
│  ┌─────────────────────┐ │        │  ┌─────────────────────┐ │
│  │ Persistent Storage  │ │   ───▶ │  │ Persistent Storage  │ │
│  └─────────────────────┘ │        │  └─────────────────────┘ │
└─────────────────────────┘        └─────────────────────────┘
```

**Recovery Components:**

**1. etcd Backup Strategy:**
```bash
#!/bin/bash
# Automated etcd backup script
ETCD_API=3
ETCD_ENDPOINTS="https://10.0.1.125:2379"
BACKUP_DIR="/backup/etcd/$(date +%Y%m%d)"
CERT_FILE="/etc/kubernetes/pki/etcd/server.crt"
KEY_FILE="/etc/kubernetes/pki/etcd/server.key"
CA_FILE="/etc/kubernetes/pki/etcd/ca.crt"

mkdir -p $BACKUP_DIR

# Create backup
etcdctl snapshot save $BACKUP_DIR/etcd-snapshot.db \
  --endpoints=$ETCD_ENDPOINTS \
  --cacert=$CA_FILE \
  --cert=$CERT_FILE \
  --key=$KEY_FILE

# Verify backup
etcdctl snapshot status $BACKUP_DIR/etcd-snapshot.db \
  --write-out=table

# Upload to cloud storage
aws s3 cp $BACKUP_DIR/etcd-snapshot.db \
  s3://k8s-backups/etcd/$(date +%Y%m%d)/

# Retention (keep 30 days)
find /backup/etcd -type f -mtime +30 -delete
```

**2. Application Data Backup:**
```yaml
# Velero backup configuration
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  template:
    includedNamespaces:
    - production
    - staging
    excludedResources:
    - events
    - events.events.k8s.io
    storageLocation: aws-backup
    volumeSnapshotLocations:
    - aws-ebs
    ttl: 720h  # 30 days

---
# Backup storage location
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: aws-backup
spec:
  provider: aws
  objectStorage:
    bucket: k8s-velero-backups
    prefix: cluster-prod
  config:
    region: us-east-1
    s3ForcePathStyle: "false"
```

**3. Cross-Region Replication:**
```yaml
# GitOps repository structure
├── clusters/
│   ├── primary/
│   │   ├── applications/
│   │   └── infrastructure/
│   └── dr/
│       ├── applications/
│       └── infrastructure/
└── shared/
    ├── base/
    └── overlays/

# ArgoCD application for DR cluster
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-dr
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://git.company.com/k8s-config
    targetRevision: HEAD
    path: clusters/dr/applications/myapp
  destination:
    server: https://k8s-dr.company.com
    namespace: production
  syncPolicy:
    automated:
      prune: false  # Manual sync for DR
      selfHeal: false
```

**4. Database Backup & Replication:**
```yaml
# PostgreSQL with streaming replication
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-ha
spec:
  instances: 3
  primaryUpdateStrategy: unsupervised
  
  postgresql:
    parameters:
      wal_level: "replica"
      max_wal_senders: "10"
      max_replication_slots: "10"
      
  backup:
    retentionPolicy: "30d"
    barmanObjectStore:
      destinationPath: "s3://postgres-backups/cluster"
      s3Credentials:
        accessKeyId:
          name: postgres-backup-creds
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: postgres-backup-creds
          key: SECRET_ACCESS_KEY
      wal:
        retention: "5d"
      data:
        retention: "30d"
```

**Recovery Procedures:**

**RTO/RPO Requirements:**
- **RTO (Recovery Time Objective)**: Maximum downtime allowed
- **RPO (Recovery Point Objective)**: Maximum data loss allowed

```yaml
Service Tiers:
├── Critical (Tier 1):
│   ├── RTO: 15 minutes
│   ├── RPO: 5 minutes
│   └── Hot standby required
├── Important (Tier 2):
│   ├── RTO: 1 hour
│   ├── RPO: 30 minutes
│   └── Warm standby acceptable
└── Standard (Tier 3):
    ├── RTO: 4 hours
    ├── RPO: 2 hours
    └── Cold recovery acceptable
```

**Automated Failover:**
```yaml
# External DNS for failover
apiVersion: externaldns.k8s.io/v1alpha1
kind: DNSEndpoint
metadata:
  name: api-failover
spec:
  endpoints:
  - dnsName: api.company.com
    recordType: A
    targets:
    - 52.1.1.1      # Primary LB
    setIdentifier: primary
    healthcheck: true
  - dnsName: api.company.com
    recordType: A
    targets:
    - 52.2.2.2      # DR LB
    setIdentifier: secondary
    healthcheck: true
```

**Recovery Automation:**
```bash
#!/bin/bash
# Disaster recovery script
set -e

BACKUP_LOCATION="s3://k8s-backups/latest"
DR_CLUSTER="https://k8s-dr.company.com"
NAMESPACE="production"

echo "Starting disaster recovery process..."

# 1. Restore etcd (if cluster-level failure)
if [[ "$CLUSTER_FAILURE" == "true" ]]; then
    echo "Restoring etcd from backup..."
    etcdctl snapshot restore $BACKUP_LOCATION/etcd-snapshot.db \
        --data-dir=/var/lib/etcd-restore
fi

# 2. Restore application data
echo "Restoring application data with Velero..."
velero restore create --from-backup daily-backup-$(date +%Y%m%d) \
    --wait

# 3. Update DNS to point to DR cluster
echo "Updating DNS records..."
kubectl apply -f dns-failover.yaml

# 4. Scale up DR applications
echo "Scaling up DR applications..."
kubectl scale deployment --all --replicas=3 -n $NAMESPACE

# 5. Verify services
echo "Verifying service health..."
for service in api web worker; do
    kubectl wait --for=condition=available deployment/$service \
        -n $NAMESPACE --timeout=300s
done

# 6. Send notification
echo "DR activation complete. Services restored."
curl -X POST https://alerts.company.com/webhook \
    -d '{"text":"DR activated successfully"}'
```

**Testing Strategy:**

**Regular DR Drills:**
```yaml
# Monthly DR test
apiVersion: batch/v1
kind: CronJob
metadata:
  name: dr-test
spec:
  schedule: "0 6 1 * *"  # First day of month at 6 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: dr-test
            image: company/dr-test:latest
            command:
            - /bin/bash
            - -c
            - |
              # Test backup restoration
              velero backup create dr-test-$(date +%s)
              
              # Test application deployment
              helm test --namespace dr-test myapp
              
              # Test data consistency
              ./verify-data-integrity.sh
              
              # Cleanup test resources
              helm uninstall myapp --namespace dr-test
```

**Monitoring & Alerting:**
```yaml
# Backup monitoring
- alert: BackupFailed
  expr: velero_backup_failure_total > 0
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Velero backup failed"
    description: "Backup failure detected for {{ $labels.backup_name }}"

- alert: etcdBackupOld
  expr: time() - etcd_backup_timestamp > 86400  # 24 hours
  labels:
    severity: warning
  annotations:
    summary: "etcd backup is old"
    description: "etcd backup is older than 24 hours"
```

**Recovery Validation:**
1. **Data integrity**: Verify restored data matches expected state
2. **Service functionality**: Test all critical user journeys
3. **Performance**: Ensure DR environment meets SLAs
4. **Dependencies**: Verify external integrations work
5. **Documentation**: Update runbooks with lessons learned

---

## 🎓 Final Summary

This interview guide covers the complete DevSecOps and Kubernetes ecosystem we built, from infrastructure provisioning to production monitoring. The key areas include:

### **Technical Breadth:**
- **Infrastructure**: AWS, Terraform, IaC principles
- **Containerization**: containerd, image security, runtime concepts  
- **Orchestration**: Kubernetes architecture, objects, scheduling
- **Networking**: CNI, service mesh, network policies
- **Automation**: Ansible, configuration management, GitOps
- **Monitoring**: Prometheus, Grafana, observability patterns
- **Security**: RBAC, secrets, admission control, policies

### **Operational Excellence:**
- **Troubleshooting**: Systematic debugging approaches
- **System Design**: Scalable, reliable architecture patterns
- **Disaster Recovery**: Backup, replication, failover strategies
- **Best Practices**: Security, performance, maintainability

### **Interview Preparation:**
- **Hands-on Experience**: Real implementation details
- **Problem-solving**: Practical troubleshooting scenarios  
- **Architecture**: System design and trade-off decisions
- **Communication**: Clear explanation of complex concepts

This guide provides both depth and breadth needed for senior DevSecOps and platform engineering roles. Each question includes not just the answer, but the reasoning and context that demonstrates true understanding of the technology stack.

---

*Remember: The best interview answers combine technical accuracy with practical experience and clear communication. Use specific examples from our implementation to illustrate your points.*