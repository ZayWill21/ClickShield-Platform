output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
description = "The name of the EKS cluster"
}

output "ecr_name" {
  value = aws_ecr_repository.ecr_clickshield_platform_repo
  description = "The name of the ECR repository"
}