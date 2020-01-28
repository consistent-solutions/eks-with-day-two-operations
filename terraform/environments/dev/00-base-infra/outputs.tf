output "aws_vpc_id" {
  value = "${module.vpc.aws_vpc_id}"
}

output "aws_subnet_ids_private" {
  value = "${module.vpc.aws_subnet_ids_private}"
}

output "aws_subnet_ids_public" {
  value = "${module.vpc.aws_subnet_ids_public}"
}

output "velero_bucket_name" {
  value = "${module.s3_velero.s3_bucket_name}"
}
