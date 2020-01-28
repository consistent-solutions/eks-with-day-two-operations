output "eks_cluster_name" {
  value = "${aws_eks_cluster.eks-cluster.name}"
}

output "eks_cluster_sg_id" {
  value = "${aws_security_group.eks-cluster.id}"
}

output "eks_cluster_version" {
  value = "${aws_eks_cluster.eks-cluster.version}"
}
