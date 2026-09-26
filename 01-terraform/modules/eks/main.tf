# =====================================================================
# EKS CLUSTER
# =====================================================================

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = local.cluster_role_arn

  vpc_config {
    subnet_ids = concat(
      var.public_subnet_ids,
      var.private_subnet_ids
    )
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = var.cluster_name
  }
}