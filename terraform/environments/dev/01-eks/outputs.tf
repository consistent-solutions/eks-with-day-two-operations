output "eks_cluster_sg_id" {
  value = "${module.eks-cluster.eks_cluster_sg_id}"
}

output "eks_cluster_name" {
  value = "${module.eks-cluster.eks_cluster_name}"
}


output "eks_cluster_version" {
  value = "${module.eks-cluster.eks_cluster_version}"
}


output "alb_ingress_controller_iam_role_arn" {
  value = "${module.iam-resources-for-apps.alb_ingress_controller_iam_role_arn}"
}

output "velero_iam_role_arn" {
  value = "${module.iam-resources-for-apps.velero_iam_role_arn}"
}

output "fluentd_cloudwatch_iam_role_arn" {
  value = "${module.iam-resources-for-apps.fluentd_cloudwatch_iam_role_arn}"
}

output "external_dns_iam_role_arn" {
  value = "${module.iam-resources-for-apps.external_dns_iam_role_arn}"
}
