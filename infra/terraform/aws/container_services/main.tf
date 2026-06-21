# 1. Deploy ECR Repository for Container Images
resource "aws_ecr_repository" "ecr_clickshield_platform_repo" {
  name = "clickshield-platform-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "IMMUTABLE"
  force_delete = true
  encryption_configuration {
    encryption_type = var.encrypt
    kms_key = aws_kms_key.ecr_kms_key.arn
  }
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
  
}

# 2. KMS Key for ECR Encryption
resource "aws_kms_key" "ecr_kms_key" {
  enable_key_rotation     = true
  description = "KMS key for encrypting ECR repository"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "auto-ecr-1",
    "Statement": [
          {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::${var.aws_account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
          },
          {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
              "AWS": ["arn:aws:iam::${var.aws_account_id}:role/GitHub_Actions_Role"]
            },
            "Action": [
              "kms:Create*",
              "kms:Describe*",
              "kms:Enable*",
              "kms:List*",
              "kms:Put*",
              "kms:Update*",
              "kms:Revoke*",
              "kms:Disable*",
              "kms:Get*",
              "kms:Delete*",
              "kms:TagResource",
              "kms:UntagResource",
              "kms:ScheduleKeyDeletion",
              "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
          },
        {
          "Sid": "Allow access through Amazon ECR for all principals in the account that are authorized to use Amazon ECR",
          "Effect": "Allow",
          "Principal": {
            "AWS": "*"
          },
          "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:CreateGrant",
            "kms:DescribeKey",
            "kms:RetireGrant"
          ],
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "kms:CallerAccount": var.aws_account_id
              "kms:ViaService": "ecr.${var.AWS_REGION}.amazonaws.com"
            }
          }
        },
        {
          "Sid": "Allow direct access to key metadata to the account",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${var.aws_account_id}:root"
          },
          "Action": [
            "kms:Describe*",
            "kms:Get*",
            "kms:List*",
            "kms:RevokeGrant"
          ],
          "Resource": "*"
        }
      ]
  })
}

# 3. KMS Key for EKS Cluster Encryption
resource "aws_kms_key" "eks_kms_key" {
    description = "KMS key for encrypting EKS cluster"
    enable_key_rotation     = true
      depends_on = [aws_iam_role.eks_cluster_role]
    policy = jsonencode({
      "Id": "key-consolepolicy-3",
      "Version": "2012-10-17",
      "Statement": [
          {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::${var.aws_account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
          },
          {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
              "AWS": ["arn:aws:iam::${var.aws_account_id}:role/GitHub_Actions_Role"]
            },
            "Action": [
              "kms:Create*",
              "kms:Describe*",
              "kms:Enable*",
              "kms:List*",
              "kms:Put*",
              "kms:Update*",
              "kms:Revoke*",
              "kms:Disable*",
              "kms:Get*",
              "kms:Delete*",
              "kms:TagResource",
              "kms:UntagResource",
              "kms:ScheduleKeyDeletion",
              "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
          },
          {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
              "AWS": aws_iam_role.eks_cluster_role.arn
            },
            "Action": [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:DescribeKey",
              "kms:GetPublicKey"
            ],
            "Resource": "*"
          },
          {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
              "AWS": aws_iam_role.eks_cluster_role.arn
            },
            "Action": [
              "kms:CreateGrant",
              "kms:ListGrants",
              "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
              "Bool": {
                "kms:GrantIsForAWSResource": "true"
              }
            }
          }
        ]
    })
  }

# 3. Deploy EKS Cluster for Container Orchestration
resource "aws_eks_cluster" "eks_cluster" {
  name    = "clickshield-eks-cluster"
  version = "1.36"
  role_arn = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  access_config {
    authentication_mode = "API"
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_kms_key.arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = var.private_subnet_ids
  }
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
  }
  depends_on = [ aws_iam_role.eks_cluster_role, aws_kms_key.eks_kms_key ]
}

resource "aws_iam_role" "eks_cluster_role" {
    name    = "eks_cluster_role"
    description = "IAM role for EKS cluster"
    assume_role_policy = jsonencode({
  "Version":"2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})
}

locals {
  policy_arns = [
          "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
          "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
          "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
          "arn:aws:iam::aws:policy/CloudWatchFullAccess",
        ]
}

resource "aws_iam_role_policy_attachment" "attach_multiple_EKS" {
  for_each   = toset(local.policy_arns)
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
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
  addon_version = "v1.36.0-eksbuild.7"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"
  addon_version = "v1.14.3-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [ aws_eks_addon.vpc-cni, aws_eks_addon.kube-proxy, aws_eks_node_group.compute ]
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-pod-identity-agent"
  addon_version = "v1.3.10-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [ aws_eks_addon.vpc-cni, aws_eks_addon.kube-proxy]
}

resource "aws_eks_addon" "cloudwatch-observability" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "amazon-cloudwatch-observability"
  addon_version = "v6.1.0-eksbuild.1"
  depends_on = [ aws_eks_node_group.compute ]
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "metrics-server" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "metrics-server"
  depends_on = [ aws_eks_node_group.compute ]
  addon_version = "v0.8.1-eksbuild.10"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "aws-network-flow-monitoring-agent" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "aws-network-flow-monitoring-agent"
  depends_on = [ aws_eks_node_group.compute ]
  addon_version = "v1.1.4-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "aws-secrets-store-csi-driver-provider" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "aws-secrets-store-csi-driver-provider"
  depends_on = [ aws_eks_node_group.compute ]
  addon_version = "v3.1.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "cert-manager" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "cert-manager"
  depends_on = [ aws_eks_node_group.compute ]
  addon_version = "v1.20.2-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
}

# resource "aws_iam_role" "network-flow-monitor-agent-role" {
#   name = "network-flow-monitor-agent-role"
#   description = "IAM role for AWS Network Flow Monitoring Agent"
#   assume_role_policy = jsonencode(data.aws_iam_policy_document.assume_role.json)
# }

# resource "aws_iam_role_policy_attachment" "example_s3" {
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchNetworkFlowMonitorAgentPublishPolicy"
#   role       = aws_iam_role.network-flow-monitor-agent-role.name
# }

# resource "aws_eks_pod_identity_association" "example" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   namespace       = "kube-system"
#   service_account = "network-flow-monitoring-agent-sa"
#   role_arn        = aws_iam_role.network-flow-monitor-agent-role.arn
# }

# module "eks_blueprints_addons" {
#   source = "aws-ia/eks-blueprints-addons/aws"
#   version = "~> 1.23.0"
#   cluster_name      = aws_eks_cluster.eks_cluster.name
#   cluster_endpoint  = aws_eks_cluster.eks_cluster.endpoint
#   cluster_version   = aws_eks_cluster.eks_cluster.version
#   oidc_provider_arn = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

#   enable_aws_load_balancer_controller           = true
#   enable_cluster_autoscaler                     = true
#   enable_secrets_store_csi_driver_provider_aws	= true
#   enable_aws_for_fluentbit                      = true
# }


#**************************Add GuardDuty, Fluentbit, Secrets Store CSI Driver, Prometheus Node Exporter and other add-ons as needed**************************

resource "aws_iam_role" "eks_cs_node_group_role" {
  name = "eks_cs_node_group_role"
  description = "IAM role for EKS node group"
  assume_role_policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "ec2.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
          }
      ]
  })
}

locals {
  policy_arns_ng = [
          "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
          "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
          "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
          "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation",
  ]
}

resource "aws_iam_role_policy_attachment" "attach_multiple" {
  for_each   = toset(local.policy_arns_ng)
  role       = aws_iam_role.eks_cs_node_group_role.name
  policy_arn = each.value
}

# 4. Deploy EKS Node Group for Worker Nodes
resource "aws_eks_node_group" "compute" {
  node_group_name = "compute"
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.eks_cs_node_group_role.arn
  ami_type = "AL2023_x86_64_STANDARD"
  instance_types = ["t3.large"]
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 1
  }
  disk_size = 30
  subnet_ids = var.private_subnet_ids
  depends_on = [ aws_iam_role.eks_cs_node_group_role, aws_eks_addon.kube-proxy, aws_eks_addon.vpc-cni ]
  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
    }
}

# -----------------Need to create IAM role for ArgoCD and attach it to the EKS cluster for ArgoCD to work properly. This is a placeholder for now.-----------------

resource "aws_eks_capability" "argoCD" {
  cluster_name              = aws_eks_cluster.eks_cluster.name
  capability_name           = "argocd"
  type                      = "ARGOCD"
  role_arn                  = aws_iam_role.example.arn
  delete_propagation_policy = "RETAIN"

  configuration {
    argo_cd {
      aws_idc {
        idc_instance_arn = "arn:aws:sso:::instance/ssoins-1234567890abcdef0"
      }
      namespace = "argocd"
    }
  }

  tags = {
    "CreatedBy" = "Terraform"
    "auto-delete" = "no"
    }
}