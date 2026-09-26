# IAM
# Ambiente Personal: Terraform cria as roles necessárias
# Ambiente Academy: Utiliza a LabRole existente


locals {
  create_iam_roles = var.environment == "personal"

  cluster_role_arn = local.create_iam_roles ? aws_iam_role.eks_cluster[0].arn : var.lab_role_arn

  node_role_arn = local.create_iam_roles ? aws_iam_role.eks_nodes[0].arn : var.lab_role_arn
}

# ---------------------------------------------------------------------
# EKS Cluster Role
# ---------------------------------------------------------------------

resource "aws_iam_role" "eks_cluster" {
  count = local.create_iam_roles ? 1 : 0
  name  = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ---------------------------------------------------------------------
# Policy necessária para o cluster EKS
# ---------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = local.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------------------------------------------------------------------
# Node Group Role
# ---------------------------------------------------------------------

resource "aws_iam_role" "eks_nodes" {
  count = local.create_iam_roles ? 1 : 0
  name  = "${var.cluster_name}-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  count      = local.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  count      = local.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  count      = local.create_iam_roles ? 1 : 0
  role       = aws_iam_role.eks_nodes[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}