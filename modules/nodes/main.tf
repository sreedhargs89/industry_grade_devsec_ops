

# Recommended: declare vpc_id variable and use it:
variable "vpc_id" {
  description = "The VPC ID where the Kubernetes cluster will be deployed"
  type        = string
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "SG for k8s control plane and workers"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K8s API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Intra-cluster communication (all protocols within SG)
  ingress {
    description      = "Cluster internal"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }

  egress {
    description = "Outbound to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "k8s-sg" })
}

locals {
  base_tags = var.tags
}

resource "aws_instance" "control_plane" {
  count                       = var.control_plane_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]

  tags = merge(local.base_tags, { Name = "k8s-control-${count.index}" })
}

resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]

  tags = merge(local.base_tags, { Name = "k8s-worker-${count.index}" })
}