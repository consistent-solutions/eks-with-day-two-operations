variable "eks_node_size" {
  description = "number of eks nodes"
}

variable "eks_node_min_count" {
  description = "min number of eks nodes"
}

variable "eks_node_max_count" {
  description = "max number of eks nodes"
}

variable "env_name" {
  description = "cluster name"
}

variable "eks_cluster_name" {
  description = "eks cluster name"
}

variable "subnet_ids" {
  description = "ids of the subnets where the cluster nodes will reside"
  type        = "list"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = "map"
}
