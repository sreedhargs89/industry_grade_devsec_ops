# 🚀 Complete DevSecOps Infrastructure Guide
## From Infrastructure to Monitoring - A Comprehensive Journey

---

# 📋 Table of Contents

1. [Infrastructure Foundation](#1-infrastructure-foundation)
2. [Container Runtime & Kubernetes](#2-container-runtime--kubernetes)
3. [Networking Deep Dive](#3-networking-deep-dive)
4. [Automation with Ansible](#4-automation-with-ansible)
5. [Monitoring Stack](#5-monitoring-stack)
6. [Architecture Overview](#6-architecture-overview)
7. [Best Practices](#7-best-practices)

---

# 1. Infrastructure Foundation

## 🏗️ What We Built

### Physical Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Master Node   │    │  Worker Node 1  │    │  Worker Node 2  │
│  13.201.18.248  │    │ 13.127.102.234  │    │  35.154.146.24  │
│   ip-10-0-1-125 │    │  ip-10-0-1-111  │    │  ip-10-0-1-137  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Concepts

#### **Infrastructure as Code (IaC)**
- **Definition**: Managing infrastructure through code rather than manual processes
- **Benefits**: Version control, reproducibility, documentation, collaboration
- **Tools Used**: Terraform (provisioning), Ansible (configuration)

#### **Cloud Computing Fundamentals**
- **EC2 Instances**: Virtual machines in AWS cloud
- **VPC (Virtual Private Cloud)**: Isolated network environment
- **Security Groups**: Virtual firewalls controlling traffic
- **SSH Key Pairs**: Secure authentication mechanism

---

# 2. Container Runtime & Kubernetes

## 🐳 Containerization

### What is a Container?
- **Lightweight virtualization**: Packages application + dependencies
- **Isolated processes**: Own filesystem, network, process space
- **Portable**: Runs consistently across environments

### Container Runtime - containerd
```yaml
Container Runtime Stack:
┌─────────────────┐
│   Application   │  ← Your app
├─────────────────┤
│   Container     │  ← Isolated environment
├─────────────────┤
│   containerd    │  ← Container runtime
├─────────────────┤
│   Linux Kernel  │  ← Host OS
└─────────────────┘
```

#### Why containerd?
- **OCI Compliant**: Follows Open Container Initiative standards
- **Kubernetes Native**: Default runtime for K8s 1.20+
- **Lightweight**: Minimal overhead, high performance
- **Production Ready**: Used by major cloud providers

## ☸️ Kubernetes Fundamentals

### Architecture Overview
```
Master Node (Control Plane):
├── API Server (kube-apiserver)     ← Entry point for all requests
├── etcd                           ← Distributed key-value store
├── Scheduler (kube-scheduler)     ← Pod placement decisions
└── Controller Manager             ← Maintains desired state

Worker Nodes:
├── kubelet                        ← Node agent
├── kube-proxy                     ← Network proxy
└── Container Runtime              ← containerd
```

### Key Components Explained

#### **API Server**
- **Purpose**: Central management hub for all cluster operations
- **Functions**: Authentication, authorization, validation, admission control
- **Communication**: REST API for all cluster interactions

#### **etcd**
- **Purpose**: Distributed key-value store for cluster state
- **Data Stored**: Pod specs, secrets, config maps, cluster state
- **Consistency**: Strong consistency using Raft consensus

#### **Scheduler**
- **Purpose**: Decides which node to place pods on
- **Factors**: Resource requirements, constraints, affinity rules
- **Algorithm**: Filtering + scoring nodes

#### **kubelet**
- **Purpose**: Node agent that manages pods
- **Functions**: Pod lifecycle, health checks, resource monitoring
- **Communication**: Reports node/pod status to API server

#### **kube-proxy**
- **Purpose**: Network proxy implementing Service abstraction
- **Functions**: Load balancing, service discovery
- **Modes**: iptables (default), IPVS, userspace

### Kubernetes Objects

#### **Pods**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```
- **Smallest deployable unit**
- **Co-located containers** sharing network and storage
- **Ephemeral** - pods come and go

#### **Deployments**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
- **Manages ReplicaSets** for rolling updates
- **Declarative updates** to pods
- **Rollback capability**

#### **Services**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```
- **Stable network endpoint** for pods
- **Load balancing** across pod replicas
- **Service discovery** via DNS

---

# 3. Networking Deep Dive

## 🌐 Kubernetes Networking Model

### The Four Networking Problems K8s Solves

1. **Container-to-container** communication (within pod)
2. **Pod-to-pod** communication (across nodes)
3. **Pod-to-service** communication
4. **External-to-service** communication

### Network Architecture
```
Physical Network:
├── Node1 (10.0.1.125) ──┐
├── Node2 (10.0.1.111) ──┼── VPC Network
└── Node3 (10.0.1.137) ──┘

Pod Network (Flannel):
├── Node1: 10.244.0.0/24
├── Node2: 10.244.1.0/24
└── Node3: 10.244.2.0/24

Service Network:
└── ClusterIP Range: 10.96.0.0/16
```

### CNI - Container Network Interface

#### **Flannel Implementation**
- **Purpose**: Provides pod-to-pod networking across nodes
- **Mechanism**: VXLAN overlay network
- **IP Management**: Subnet allocation per node
- **Routing**: Kernel routing table + bridge networking

#### **How Flannel Works**
```
Pod A (10.244.1.2) on Node1 → Pod B (10.244.2.3) on Node2

1. Pod A sends packet to 10.244.2.3
2. Node1 kernel routes to flannel.1 interface
3. Flannel encapsulates in VXLAN (UDP)
4. Physical network routes to Node2
5. Node2 flannel decapsulates
6. Packet delivered to Pod B
```

### Service Types

#### **ClusterIP** (Default)
- **Scope**: Internal cluster communication only
- **Use Case**: Database, internal APIs
- **Access**: Via service name (DNS)

#### **NodePort**
- **Scope**: External access via any node's IP
- **Port Range**: 30000-32767
- **Use Case**: Development, testing

#### **LoadBalancer**
- **Scope**: Cloud provider load balancer
- **Use Case**: Production external services
- **Limitation**: Requires cloud integration

---

# 4. Automation with Ansible

## 🔧 Configuration Management

### Why Ansible?
- **Agentless**: SSH-based, no client installation
- **Idempotent**: Can run multiple times safely
- **Declarative**: Describe desired state
- **Simple**: YAML syntax, readable

### Ansible Architecture
```
Control Node (Your Machine):
├── Inventory (hosts definition)
├── Playbooks (tasks definition)
└── Ansible Engine

Managed Nodes (Kubernetes Nodes):
└── SSH Access + Python
```

### Inventory Structure
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

### Playbook Concepts

#### **Tasks**
- **Atomic operations**: Install package, copy file, start service
- **Modules**: Reusable code for specific operations
- **Idempotency**: Check current state before making changes

#### **Handlers**
- **Event-driven**: Only run when notified
- **Use Case**: Restart services after config changes

#### **Variables**
- **Inventory variables**: Host-specific data
- **Group variables**: Shared across host groups
- **Playbook variables**: Defined in playbook

### Our Automation Pipeline

#### **1. Common Setup** (`k8s-playbook-common.yml`)
```yaml
Tasks Performed:
├── Update package cache
├── Install base dependencies (curl, ca-certificates)
├── Install containerd container runtime
├── Configure containerd with systemd cgroups
├── Load kernel modules (br_netfilter, overlay)
├── Set sysctl parameters for networking
├── Add Kubernetes repository
├── Install kubelet, kubeadm, kubectl
└── Hold package versions (prevent updates)
```

#### **2. Master Initialization** (`k8s-master.yml`)
```yaml
Tasks Performed:
├── Initialize cluster with kubeadm
├── Configure pod network CIDR (10.244.0.0/16)
├── Set up kubectl config for ubuntu user
└── Generate join command for workers
```

#### **3. Worker Join** (`k8s-worker.yml`)
```yaml
Tasks Performed:
└── Join worker nodes to cluster using token
```

#### **4. Monitoring Setup** (`k8s-monitoring.yml`)
```yaml
Tasks Performed:
├── Install Helm package manager
├── Add Prometheus Community helm repository
├── Deploy kube-prometheus-stack
└── Configure NodePort services for external access
```

---

# 5. Monitoring Stack

## 📊 Observability Fundamentals

### The Three Pillars of Observability

1. **Metrics**: Numerical measurements over time
2. **Logs**: Event records with timestamps
3. **Traces**: Request journey through system

### Monitoring Architecture
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Metrics    │    │    Logs     │    │   Traces    │
│ (Prometheus)│    │ (Grafana)   │    │  (Jaeger)   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                    │                    │
       └────────────────────┼────────────────────┘
                           │
                    ┌─────────────┐
                    │  Grafana    │
                    │ (Dashboard) │
                    └─────────────┘
```

## 🔥 Prometheus Deep Dive

### What is Prometheus?
- **Time-series database**: Stores metrics with timestamps
- **Pull-based model**: Scrapes metrics from targets
- **PromQL**: Powerful query language for metrics
- **Alerting**: Rule-based alert generation

### Data Model
```
Metric Name: http_requests_total
Labels: {method="GET", status="200", endpoint="/api"}
Value: 1047
Timestamp: 1634567890
```

### Scraping Architecture
```
Prometheus Server:
├── Scrape Config ──→ Service Discovery
├── Storage Engine ──→ Time Series DB
├── Query Engine ──→ PromQL Processor
└── Alert Manager ──→ Notification Router
```

### Key Components in Our Setup

#### **Prometheus Server**
- **Role**: Central metrics collector and storage
- **Scrape Targets**: All services with /metrics endpoint
- **Storage**: 10 days retention (configurable)
- **Query Interface**: Web UI + API

#### **Node Exporter**
- **Purpose**: Hardware and OS metrics
- **Deployment**: DaemonSet (one per node)
- **Metrics**: CPU, memory, disk, network usage
- **Port**: 9100/tcp

#### **kube-state-metrics**
- **Purpose**: Kubernetes object state metrics
- **Scope**: Pods, deployments, services, nodes
- **Deployment**: Single replica per cluster
- **Metrics**: Pod restarts, deployment status, resource quotas

#### **Alertmanager**
- **Purpose**: Alert routing and notification
- **Features**: Grouping, inhibition, silencing
- **Integrations**: Email, Slack, PagerDuty, webhooks
- **Configuration**: Routing rules and receivers

## 📈 Grafana Deep Dive

### What is Grafana?
- **Visualization platform**: Create dashboards and charts
- **Data Sources**: Prometheus, InfluxDB, Elasticsearch, etc.
- **Templating**: Dynamic dashboards with variables
- **Alerting**: Visual alert rules and notifications

### Dashboard Architecture
```
Dashboard:
├── Panels (Charts, Tables, Stats)
│   ├── Queries (PromQL)
│   ├── Visualizations (Graph, Gauge, Heatmap)
│   └── Thresholds (Warning/Critical levels)
├── Variables (Dynamic filtering)
└── Annotations (Event markers)
```

### Our Pre-built Dashboards

#### **Kubernetes Cluster Overview**
- **Metrics**: Node status, pod count, resource usage
- **Panels**: CPU/Memory utilization, network traffic
- **Filters**: By namespace, node, workload

#### **Node Exporter Dashboards**
- **System Metrics**: CPU, memory, disk, network
- **Hardware Info**: Temperature, fan speed, power
- **OS Metrics**: Process count, load average, uptime

#### **Application Dashboards**
- **Pod Metrics**: Resource usage per pod
- **Service Metrics**: Request rate, latency, errors
- **Custom Metrics**: Application-specific measurements

## 🚨 Alerting Strategy

### Alert Lifecycle
```
1. Metric Collection → 2. Rule Evaluation → 3. Alert Firing
          ↓                       ↓                 ↓
4. Alert Routing → 5. Notification → 6. Resolution
```

### Common Alert Rules
```yaml
High CPU Usage:
- expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
- for: 5m
- severity: warning

Pod Crash Looping:
- expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
- for: 5m
- severity: critical

Disk Space Low:
- expr: (1 - node_filesystem_avail_bytes/node_filesystem_size_bytes) * 100 > 90
- for: 10m
- severity: warning
```

---

# 6. Architecture Overview

## 🏛️ Complete System Architecture

### Infrastructure Layer
```
Cloud Provider (AWS):
├── VPC Network (10.0.0.0/16)
├── Security Groups (Firewall rules)
├── EC2 Instances (3 nodes)
└── SSH Key Pairs (Secure access)
```

### Container Layer
```
Container Runtime:
├── containerd (CRI-compliant)
├── runc (Low-level runtime)
└── Container Images (Application packages)
```

### Orchestration Layer
```
Kubernetes Control Plane:
├── API Server (REST interface)
├── etcd (Cluster state)
├── Scheduler (Pod placement)
└── Controller Manager (Desired state)

Kubernetes Workers:
├── kubelet (Node agent)
├── kube-proxy (Network proxy)
└── CNI Plugin (Flannel)
```

### Network Layer
```
Network Stack:
├── Physical Network (AWS VPC)
├── Pod Network (Flannel/VXLAN)
├── Service Network (ClusterIP)
└── External Access (NodePort/LoadBalancer)
```

### Monitoring Layer
```
Observability Stack:
├── Metrics Collection (Prometheus)
├── Metrics Storage (Time-series DB)
├── Visualization (Grafana)
├── Alerting (AlertManager)
└── Log Aggregation (Future: ELK Stack)
```

### Automation Layer
```
Infrastructure as Code:
├── Provisioning (Terraform)
├── Configuration (Ansible)
├── Package Management (Helm)
└── CI/CD Pipeline (Future: GitLab/Jenkins)
```

## 🔄 Data Flow

### Application Deployment Flow
```
1. Developer commits code
2. CI/CD builds container image
3. Helm chart deployed to K8s
4. Scheduler places pods on nodes
5. Service creates stable endpoint
6. Ingress routes external traffic
7. Monitoring collects metrics
8. Alerts fire if issues detected
```

### Monitoring Data Flow
```
1. Applications expose /metrics endpoint
2. Prometheus scrapes metrics (30s interval)
3. Metrics stored in time-series DB
4. Grafana queries Prometheus
5. Dashboards visualize metrics
6. Alert rules evaluate conditions
7. AlertManager routes notifications
8. Teams respond to alerts
```

---

# 7. Best Practices

## 🎯 Infrastructure Best Practices

### Security
- **Principle of Least Privilege**: Minimum required permissions
- **Network Segmentation**: Isolate components with security groups
- **Secret Management**: Use K8s secrets, not hardcoded values
- **Regular Updates**: Keep systems and dependencies updated

### Scalability
- **Horizontal Scaling**: Add more pods/nodes vs. larger instances
- **Resource Limits**: Set CPU/memory limits on containers
- **Auto-scaling**: HPA (pods) and CA (nodes)
- **Load Testing**: Validate performance under load

### Reliability
- **High Availability**: Multiple replicas across zones
- **Health Checks**: Liveness and readiness probes
- **Circuit Breakers**: Fail fast, prevent cascade failures
- **Disaster Recovery**: Backup strategies and recovery procedures

### Monitoring
- **SLI/SLO/SLA**: Define service level indicators and objectives
- **Golden Signals**: Latency, traffic, errors, saturation
- **Alert Fatigue**: Avoid too many alerts, focus on actionable items
- **Runbooks**: Document troubleshooting procedures

## 🔧 Operational Best Practices

### Configuration Management
- **Infrastructure as Code**: Version control all infrastructure
- **Immutable Infrastructure**: Replace rather than modify
- **Configuration Drift**: Regular compliance checks
- **Environment Parity**: Dev/staging mirrors production

### Deployment Strategies
- **Rolling Updates**: Zero-downtime deployments
- **Blue-Green**: Parallel environment switching
- **Canary**: Gradual traffic shifting
- **Feature Flags**: Runtime feature toggles

### Incident Response
- **On-call Rotation**: Shared responsibility model
- **Incident Commander**: Single point of coordination
- **Post-mortems**: Blameless culture, focus on learning
- **Communication**: Regular updates to stakeholders

---

## 🎓 Conclusion

This guide covered the complete journey from infrastructure provisioning to production monitoring. The key concepts include:

1. **Container-first Architecture**: Portable, scalable applications
2. **Kubernetes Orchestration**: Automated container management
3. **Infrastructure as Code**: Repeatable, version-controlled infrastructure
4. **Comprehensive Monitoring**: Proactive issue detection and resolution
5. **Automation**: Reduced manual effort and human error

The architecture we built provides a solid foundation for modern applications with built-in scalability, reliability, and observability.

---

## 📚 Additional Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Prometheus Documentation**: https://prometheus.io/docs/
- **Grafana Documentation**: https://grafana.com/docs/
- **Ansible Documentation**: https://docs.ansible.com/
- **containerd Documentation**: https://containerd.io/docs/

---

*This guide represents a production-ready setup suitable for enterprise environments. Each component can be further customized based on specific requirements and constraints.*