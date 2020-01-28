
variable "env_name" {
  description = "Name of Cluster"
}

variable "vpc_id" {
  description = "id of vpc where cluster will live"
}

variable "subnet_ids" {
  description = "ids of the subnets where the cluster will reside"
  type        = "list"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = "map"
}

variable "endpoint_public_access" {
  description = "enable public access"
  default = false
}

variable "eks_version" {
  description = "version of eks"
}
