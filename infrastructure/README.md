# Simple DevSecOps Infrastructure

Simple Terraform setup to create a basic AWS infrastructure with VPC, subnets, and EC2 instance.

## What This Creates

- **VPC**: Virtual Private Cloud (10.0.0.0/16)
- **Public Subnet**: For internet-facing resources (10.0.1.0/24)
- **Private Subnet**: For internal resources (10.0.2.0/24)
- **Internet Gateway**: For internet access
- **Security Group**: Allow SSH, HTTP, and HTTPS
- **EC2 Instance**: Web server with Apache installed

## Architecture

```
Internet
    |
Internet Gateway
    |
┌─────────────────────────────┐
│         VPC                 │
│       10.0.0.0/16           │
│                             │
│  ┌─────────────────────┐    │
│  │  Public Subnet      │    │
│  │   10.0.1.0/24       │    │
│  │                     │    │
│  │  ┌─────────────┐    │    │
│  │  │ EC2 Web     │    │    │
│  │  │ Server      │    │    │
│  │  └─────────────┘    │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │  Private Subnet     │    │
│  │   10.0.2.0/24       │    │
│  │                     │    │
│  └─────────────────────┘    │
└─────────────────────────────┘
```

## Quick Start

### Prerequisites
- AWS CLI configured
- Terraform installed
- (Optional) AWS Key Pair created

### Deploy

1. **Navigate to terraform directory:**
   ```bash
   cd infrastructure/terraform
   ```

2. **Copy and edit configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and add your key_pair_name if you want SSH access
   ```

3. **Deploy infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Get outputs:**
   ```bash
   terraform output
   ```

### Access Your Instance

After deployment:
- **Web Server**: Visit the `web_url` from terraform output
- **SSH**: Use the `ssh_command` from terraform output (if key pair specified)

### Clean Up

```bash
terraform destroy
```

## What's Included

- **Simple VPC setup** with public and private subnets
- **EC2 instance** with Apache web server pre-installed
- **Security group** allowing HTTP, HTTPS, and SSH access
- **Basic networking** with Internet Gateway and routing

---

**Perfect for learning Terraform and AWS basics!**

## 🔐 Security Features

### Network Security
- **VPC Flow Logs**: Complete network traffic logging
- **Network ACLs**: Subnet-level access control
- **Security Groups**: Instance-level firewall rules
- **WAF Protection**: Layer 7 DDoS and application attack protection
- **Private Subnets**: Application servers isolated from internet

### Instance Security
- **Security Hardened AMIs**: Latest Amazon Linux with security updates
- **Encrypted Storage**: All EBS volumes encrypted at rest
- **IAM Roles**: Least privilege access with specific permissions
- **SSH Hardening**: Key-based authentication only, no root access
- **Intrusion Detection**: fail2ban for SSH protection
- **File Integrity**: AIDE for file system monitoring
- **Antivirus**: ClamAV with daily scans
- **Security Scanning**: rkhunter and Lynis auditing

### Monitoring & Compliance
- **CloudWatch Monitoring**: System and application metrics
- **Log Aggregation**: Centralized logging via CloudWatch Logs
- **Security Logging**: SSH access and security events
- **Automated Alerting**: CloudWatch alarms for critical events
- **Access Logging**: ALB access logs stored in S3

## 🚀 Quick Start

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **AWS CLI** configured with credentials
4. **SSH Key Pair** created in AWS (optional but recommended)

### Step 1: Clone and Navigate

```bash
git clone https://github.com/your-username/industry_grade_devsec_ops.git
cd industry_grade_devsec_ops/infrastructure/terraform
```

### Step 2: Configure Variables

```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration file
vim terraform.tfvars
```

**Important**: Update these values in `terraform.tfvars`:

```hcl
# Add your AWS key pair name (create one in AWS EC2 console first)
key_pair_name = "your-key-pair-name"

# Restrict SSH access (replace with your IP)
ssh_cidr_blocks = ["YOUR.IP.ADDRESS/32"]

# Update for your environment
project_name = "your-project-name"
owner = "Your-Team-Name"
```

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

The deployment takes approximately 5-10 minutes.

### Step 4: Access Your Infrastructure

After deployment, Terraform outputs important information:

```bash
# Get important connection details
terraform output

# Example output:
# application_url = "http://your-alb-dns-name.us-east-1.elb.amazonaws.com"
# ssh_connection_command = "ssh -i ~/.ssh/your-key.pem ec2-user@bastion-ip"
```

## 📋 Architecture Details

### Network Design

| Component | CIDR | Purpose |
|-----------|------|---------|
| VPC | 10.0.0.0/16 | Main network (65,536 IPs) |
| Public Subnet 1 | 10.0.1.0/24 | Internet-facing resources (254 IPs) |
| Public Subnet 2 | 10.0.2.0/24 | Internet-facing resources (254 IPs) |
| Private Subnet 1 | 10.0.11.0/24 | Application servers (254 IPs) |
| Private Subnet 2 | 10.0.12.0/24 | Application servers (254 IPs) |

### Security Groups

| Security Group | Purpose | Inbound Rules |
|---------------|---------|---------------|
| Bastion | SSH access host | SSH (22) from specified CIDRs |
| ALB | Load balancer | HTTP (80), HTTPS (443) from internet |
| Application | App servers | HTTP (8080) from ALB, SSH from Bastion |
| Database | Database servers | DB ports from Application SG |
| Monitoring | Observability | Prometheus, Grafana ports from VPC |

### Monitoring Stack

- **CloudWatch Agent**: System and custom metrics
- **Node Exporter**: Prometheus-compatible metrics (port 9100)
- **Application Logs**: Centralized via CloudWatch Logs
- **Security Logs**: SSH access and security events
- **Flow Logs**: Complete network traffic analysis

## 🛠️ Customization

### Environment-Specific Configurations

#### Development Environment
```hcl
environment = "dev"
instance_type = "t3.micro"
min_size = 1
max_size = 2
single_nat_gateway = true
```

#### Production Environment
```hcl
environment = "prod"
instance_type = "t3.small"
min_size = 2
max_size = 10
single_nat_gateway = false  # HA across AZs
enable_deletion_protection = true
```

### Scaling Configuration

The infrastructure supports automatic scaling based on CPU utilization:

- **Scale Up**: CPU > 80% for 2 consecutive periods (4 minutes)
- **Scale Down**: CPU < 10% for 2 consecutive periods (4 minutes)
- **Cooldown**: 5 minutes between scaling actions

### Adding Custom Applications

1. **Modify User Data**: Edit `modules/ec2/user_data.sh`
2. **Update Security Groups**: Add required ports in `modules/security/main.tf`
3. **Configure Health Checks**: Update ALB target group health check path

## 🔍 Monitoring and Observability

### CloudWatch Dashboards

Access AWS CloudWatch console to view:
- EC2 instance metrics (CPU, memory, disk)
- Auto Scaling Group metrics
- Application Load Balancer metrics
- VPC Flow Logs analysis

### Log Groups

| Log Group | Purpose | Retention |
|-----------|---------|-----------|
| `/aws/ec2/{project}/system` | System logs | 30 days |
| `/aws/ec2/{project}/security` | Security events | 90 days |
| `/aws/wafv2/{project}` | WAF logs | 30 days |

### Prometheus Integration

Node Exporter is installed on all instances (port 9100) for Prometheus monitoring:

```bash
# Example Prometheus scrape config
- job_name: 'aws-ec2'
  ec2_sd_configs:
    - region: us-east-1
      port: 9100
```

## 🧪 Testing

### Infrastructure Validation

```bash
# Validate Terraform configuration
terraform validate

# Check formatting
terraform fmt -check

# Plan with detailed output
terraform plan -detailed-exitcode
```

### Security Testing

```bash
# SSH to bastion host
ssh -i ~/.ssh/your-key.pem ec2-user@$(terraform output -raw bastion_public_ip)

# Check security hardening report
sudo cat /var/log/security-hardening-report.txt

# Verify services are running
sudo systemctl status fail2ban
sudo systemctl status node_exporter
sudo systemctl status webapp
```

### Application Testing

```bash
# Test application via load balancer
curl http://$(terraform output -raw application_load_balancer_dns_name)

# Test health endpoint
curl http://$(terraform output -raw application_load_balancer_dns_name)/health
```

## 🔄 Maintenance

### Regular Tasks

1. **Security Updates**: Automatic via yum-cron
2. **Certificate Renewal**: Manual (consider Let's Encrypt automation)
3. **Log Rotation**: Automatic via CloudWatch retention policies
4. **Backup Verification**: EBS snapshots via AWS Backup (add as needed)

### Troubleshooting

#### Common Issues

**1. Terraform Apply Fails**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Validate configuration
terraform validate

# Check specific resource
terraform state show aws_instance.bastion
```

**2. Instances Not Healthy**
```bash
# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names your-asg-name

# Check target group health
aws elbv2 describe-target-health --target-group-arn your-target-group-arn

# SSH to instance and check logs
ssh -i ~/.ssh/your-key.pem ec2-user@instance-ip
sudo journalctl -u webapp
```

**3. High Costs**
```bash
# Check running instances
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`]'

# Review NAT Gateway usage
aws ec2 describe-nat-gateways

# Consider using single NAT Gateway for dev environments
```

## 💰 Cost Optimization

### Development Environment
- Use t3.micro instances (free tier eligible)
- Single NAT Gateway instead of per-AZ
- Shorter log retention periods
- Schedule instances to stop during non-business hours

### Production Environment
- Use Reserved Instances for predictable workloads
- Enable detailed monitoring for better scaling decisions
- Implement automated instance scheduling
- Use S3 lifecycle policies for log archival

### Cost Monitoring
```bash
# Enable AWS Cost Explorer
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost
```

## 🚨 Security Best Practices

### Before Production Deployment

1. **Review Security Groups**: Ensure minimal necessary access
2. **SSH Key Management**: Use AWS Systems Manager Session Manager instead of SSH where possible
3. **Secrets Management**: Implement AWS Secrets Manager for application secrets
4. **Backup Strategy**: Configure AWS Backup for critical data
5. **Compliance**: Run AWS Config rules for compliance monitoring

### Ongoing Security

1. **Regular Updates**: Monitor AWS Security Bulletins
2. **Access Reviews**: Regularly review IAM permissions
3. **Penetration Testing**: Schedule regular security assessments
4. **Incident Response**: Have a documented incident response plan

## 📞 Support

For questions, issues, or contributions:

1. **Issues**: Create an issue in the repository
2. **Discussions**: Use repository discussions for questions
3. **Security Issues**: Report privately via security advisory

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

**Built with 💜 for DevSecOps practitioners by DevSecOps practitioners**