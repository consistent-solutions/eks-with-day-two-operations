
output "eks_node_iam_role_arn" {
  value = "${aws_iam_role.eks-node.arn}"
}
