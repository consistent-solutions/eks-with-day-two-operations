variable "env_name" {
  description = "cluster name"
}

variable "velero_bucket_name" {
  description = "bucket used by velero to place backups"
}

variable "hosted_zone_id" {
  description = "id of hosted zone"
}

variable "eks_node_iam_role_arn" {
  description = "arn of eks node iam role"
}

#
# variable "default_tags" {
#   description = "Default tags for all resources"
#   type        = "map"
# }
