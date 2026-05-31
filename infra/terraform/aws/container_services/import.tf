
import {
  to = aws_kms_key.ecr_kms_arn
  id = var.ecr_kms_arn
}
import {
  to = aws_kms_key.eks_kms_arn
  id = var.eks_kms_arn
}

import {
  to = aws_iam_role.eks_cluster_role
  id = var.eks_cluster_role
}

import {
  to = aws_iam_role.eks_node_group_role
  id = var.eks_node_group_role
}