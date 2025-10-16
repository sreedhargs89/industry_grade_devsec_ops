#!/bin/bash

# Security Hardened User Data Script for DevSecOps Infrastructure

# Set strict bash mode
set -euo pipefail

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/user-data.log
}

log "Starting security hardened instance initialization"

# Update system packages
log "Updating system packages"
yum update -y

# Install essential security and monitoring tools
log "Installing essential packages"
yum install -y \
    amazon-cloudwatch-agent \
    aws-cli \
    htop \
    iotop \
    nmap \
    tcpdump \
    wireshark \
    fail2ban \
    rkhunter \
    chkrootkit \
    aide \
    clamav \
    clamav-update \
    lynis \
    git \
    curl \
    wget \
    unzip \
    jq \
    docker

# Start and enable Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose
log "Installing Docker Compose"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node Exporter for Prometheus monitoring
log "Installing Node Exporter"
useradd --no-create-home --shell /bin/false node_exporter
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvf node_exporter-1.6.1.linux-amd64.tar.gz
cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create Node Exporter systemd service
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

# Security Hardening

# 1. SSH Hardening
log "Hardening SSH configuration"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
cat > /etc/ssh/sshd_config << EOF
Protocol 2
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/libexec/openssh/sftp-server
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 2
EOF

systemctl restart sshd

# 2. Configure fail2ban for SSH protection
log "Configuring fail2ban"
systemctl start fail2ban
systemctl enable fail2ban

cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3
bantime = 3600
EOF

systemctl restart fail2ban

# 3. File system security
log "Setting up file system security"
# Make /tmp noexec
mount -o remount,noexec /tmp

# Set proper permissions
chmod 700 /root
chmod 600 /etc/ssh/sshd_config

# 4. Kernel security parameters
log "Configuring kernel security parameters"
cat >> /etc/sysctl.conf << EOF

# IP Spoofing protection
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1

# Ignore ICMP ping requests
net.ipv4.icmp_echo_ignore_all = 1

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Ignore ICMP redirect
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Log Martians
net.ipv4.conf.all.log_martians = 1

# Ignore ping
net.ipv4.icmp_echo_ignore_broadcasts = 1

# SYN flood protection
net.ipv4.tcp_syncookies = 1
EOF

sysctl -p

# 5. Configure automatic security updates
log "Configuring automatic security updates"
yum install -y yum-cron
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
sed -i 's/update_level = default/update_level = security/' /etc/yum/yum-cron.conf
systemctl start yum-cron
systemctl enable yum-cron

# 6. Install and configure AIDE (file integrity monitoring)
log "Configuring AIDE"
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Create daily AIDE check
cat > /etc/cron.daily/aide << EOF
#!/bin/bash
/usr/sbin/aide --check
EOF
chmod +x /etc/cron.daily/aide

# 7. Configure ClamAV antivirus
log "Configuring ClamAV"
freshclam
systemctl start clamd@scan
systemctl enable clamd@scan

# Create daily virus scan
cat > /etc/cron.daily/clamav << EOF
#!/bin/bash
/usr/bin/freshclam --quiet
/usr/bin/clamscan -r /home /var --quiet --infected --remove
EOF
chmod +x /etc/cron.daily/clamav

# 8. Install and run security scanners
log "Running initial security scans"
# Update rkhunter database
rkhunter --update --quiet

# Run Lynis security audit
lynis audit system --quiet

# CloudWatch Agent Configuration
log "Configuring CloudWatch Agent"
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
${cloudwatch_config}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# 9. Application Setup (Sample Web Server)
log "Setting up sample application"
mkdir -p /opt/app
cat > /opt/app/app.py << 'EOF'
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import time
import os

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {
                'status': 'healthy',
                'timestamp': int(time.time()),
                'hostname': os.uname().nodename
            }
            self.wfile.write(json.dumps(response).encode())
        elif self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            html = f"""
            <html>
            <head><title>DevSecOps Demo App</title></head>
            <body>
                <h1>Industry Grade DevSecOps Infrastructure</h1>
                <p>Instance: {os.uname().nodename}</p>
                <p>Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S')}</p>
                <p><a href="/health">Health Check</a></p>
            </body>
            </html>
            """
            self.wfile.write(html.encode())
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), HealthHandler)
    print("Starting server on port 8080...")
    server.serve_forever()
EOF

chmod +x /opt/app/app.py

# Create systemd service for the app
cat > /etc/systemd/system/webapp.service << EOF
[Unit]
Description=DevSecOps Demo Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 /opt/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start webapp
systemctl enable webapp

# 10. Logging and Monitoring Setup
log "Setting up logging and monitoring"

# Configure rsyslog for centralized logging
cat >> /etc/rsyslog.conf << EOF

# Security event logging
authpriv.*                                       /var/log/secure
*.info;mail.none;authpriv.none;cron.none         /var/log/messages
EOF

systemctl restart rsyslog

# 11. Final Security Checks
log "Running final security checks"

# Set proper file permissions
find /etc -type f -name "*.conf" -exec chmod 644 {} \;
find /etc -type f -name "*.key" -exec chmod 600 {} \;

# Disable unnecessary services
systemctl disable postfix 2>/dev/null || true
systemctl disable cups 2>/dev/null || true
systemctl disable avahi-daemon 2>/dev/null || true

# Clean up
yum clean all
rm -rf /tmp/*
rm -rf /var/tmp/*

# Create security report
log "Generating security report"
cat > /var/log/security-hardening-report.txt << EOF
Security Hardening Report
========================
Date: $(date)
Instance: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AMI: $(curl -s http://169.254.169.254/latest/meta-data/ami-id)

Security Measures Implemented:
- SSH hardening (disabled root login, password auth)
- fail2ban for intrusion prevention
- Kernel security parameters configured
- Automatic security updates enabled
- AIDE file integrity monitoring
- ClamAV antivirus with daily scans
- Security scanners (rkhunter, Lynis)
- CloudWatch monitoring agent
- Application firewall via security groups
- Encrypted EBS volumes
- IAM roles with least privilege

Services Running:
- Node Exporter (port 9100)
- Demo Web App (port 8080)
- SSH (port 22)
- CloudWatch Agent
- fail2ban
- ClamAV

Regular Security Tasks:
- Daily AIDE integrity checks
- Daily virus scans
- Automatic security updates
- Log monitoring via CloudWatch
EOF

log "Security hardening completed successfully"
log "Instance is ready for production use"

# Send notification to CloudWatch Logs
echo "Security hardening completed on $(date)" > /dev/stdout