# =====================================================================
# EKS MANAGED NODE GROUP
# =====================================================================

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodes"

  node_role_arn = local.node_role_arn
  subnet_ids    = var.private_subnet_ids

  version  = aws_eks_cluster.this.version
  ami_type = "AL2023_x86_64_STANDARD"

  instance_types = [
    var.node_instance_type
  ]

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  depends_on = [
    aws_eks_cluster.this
  ]

  tags = {
    Name = "${var.cluster_name}-nodes"
  }
}