output "alb_ingress_controller_iam_role_arn" {
  value = "${aws_iam_role.alb_ingress_controller_role.arn}"
}


output "velero_iam_role_arn" {
  value = "${aws_iam_role.velero_role.arn}"
}


output "fluentd_cloudwatch_iam_role_arn" {
  value = "${aws_iam_role.fluentd_cloudwatch_role.arn}"
}


output "external_dns_iam_role_arn" {
  value = "${aws_iam_role.external_dns_role.arn}"
}
