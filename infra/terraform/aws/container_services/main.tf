# module "networking" {
#   source = "../networking"
#   public_subnet_cidrs  = var.public_subnet_cidrs
#   private_subnet_cidrs = var.private_subnet_cidrs
#   availability_zones   = var.availability_zones
#   VPC_CIDR             = var.VPC_CIDR
#   AWS_REGION           = var.AWS_REGION
#   ZEROS                = var.ZEROS
# }

# 1. Deploy ECR Repository for Container Images
resource "aws_ecr_repository" "ecr_clickshield_platform_repo" {
  name = "clickshield-platform-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
  force_delete = true
  encryption_configuration {
    encryption_type = var.encrypt
    kms_key = aws_kms_key.ecr_kms_arn.arn
  }
}

# 2. Create KMS Key for ECR Encryption
resource "aws_kms_key" "ecr_kms_arn" {
    description = "KMS key for encrypting ECR repository"
}

import {
  to = aws_kms_key.ecr_kms_arn
  id = var.ecr_kms_arn
}

# 3. Create KMS Key for EKS Cluster Encryption
resource "aws_kms_key" "eks_kms_arn" {
    description = "KMS key for encrypting EKS cluster"
}

import {
  to = aws_kms_key.eks_kms_arn
  id = var.eks_kms_arn
}

# 3. Deploy EKS Cluster for Container Orchestration
resource "aws_eks_cluster" "eks_cluster" {
  name    = "clickshield-eks-cluster"
  version = "1.35"
  role_arn = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  access_config {
    authentication_mode = "API"
  }

  encryption_config {
    provider {
      key_arn = var.eks_kms_arn
    }
    resources = "secrets"
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids = [
        var.private_subnet_ids[*] # in to import mode networking
    ]
  }
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
  depends_on = [ aws_iam_role.eks_cluster_role, aws_kms_key.eks_kms_arn ]
}

resource "aws_iam_role" "eks_cluster_role" {
    name    = "eks_cluster_role"
    description = "IAM role for EKS cluster"
    assume_role_policy = jsonencode({})
}

import {
  to = aws_iam_role.eks_cluster_role
  id = var.eks_cluster_role
}

# Create EKS add-ons:
resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
  addon_version = "v1.22.1-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"
  addon_version = "v1.35.3-eksbuild.11"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"
  addon_version = "v1.14.3-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-pod-identity-agent"
  addon_version = "v1.3.10-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "cloudwatch-observability" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "amazon-cloudwatch-observability"
  addon_version = "v6.1.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "metrics-server" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "metrics-server"
  addon_version = "v0.8.1-eksbuild.10"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "amazon-ebs-csi-driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "amazon-ebs-csi-driver"
  addon_version = "v1.60.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

# **************************Add GuardDuty, Fluentbit, Secrets Store CSI Driver, Prometheus Node Exporter and other add-ons as needed**************************


data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks_node_group_role"
  description = "IAM role for EKS node group"
  assume_role_policy = jsonencode({})
}

import {
  to = aws_iam_role.eks_node_group_role
  id = var.eks_node_group_role
}
# 4. Deploy EKS Node Group for Worker Nodes
resource "aws_eks_node_group" "compute" {
  node_group_name = "compute"
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  release_version = data.aws_ssm_parameter.eks_ami_release_version.value
  ami_type = AL2023_x86_64_STANDARD
  instance_types = "t3.large"
  scaling_config {
    desired_size = 1
    max_size = 2
    min_size = 1
  }
  disk_size = 30
  subnet_ids = var.private_subnet_cidrs[*].id
  depends_on = [ aws_iam_role.eks_node_group_role, aws_eks_addon.kube-proxy, aws_eks_addon.vpc-cni ]
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
    }
}