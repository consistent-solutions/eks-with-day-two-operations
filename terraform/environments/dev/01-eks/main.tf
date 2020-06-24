terraform {
  required_version = "= 0.11.2"

  backend "s3" {
    bucket = "cs-eks-example-solution"
    key    = "dev/01-eks.tf"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


data "terraform_remote_state" "00-base-infra" {
  backend = "s3"

  config {
    bucket = "cs-eks-example-solution"
    key    = "dev/00-base-infra.tf"
    region = "us-east-1"
  }
}


module "eks-cluster" {
  source = "../../../modules/eks-cluster"

  env_name                 = "${var.env_name}"
  default_tags             = "${var.default_tags}"
  vpc_id                   = "${data.terraform_remote_state.00-base-infra.aws_vpc_id}"
  subnet_ids               = "${data.terraform_remote_state.00-base-infra.aws_subnet_ids_private}"
  eks_version              = "${var.eks_version}"
}

module "eks-node" {
  source = "../../../modules/eks-node"

  env_name                 = "${var.env_name}"
  default_tags             = "${var.default_tags}"
  eks_cluster_name         = "${module.eks-cluster.eks_cluster_name}"
  subnet_ids               = "${data.terraform_remote_state.00-base-infra.aws_subnet_ids_private}"
  eks_node_size            = "${var.eks_node_size}"
  eks_node_min_count       = "${var.eks_node_min}"
  eks_node_max_count       = "${var.eks_node_max}"

}

module "iam-resources-for-apps" {
  source = "../../../modules/iam-resources-for-apps"

  env_name                 = "${var.env_name}"
  # default_tags           = "${var.default_tags}"
  eks_node_iam_role_arn    = "${module.eks-node.eks_node_iam_role_arn}"
  velero_bucket_name       = "${data.terraform_remote_state.00-base-infra.velero_bucket_name}"
  hosted_zone_id           = "${var.hosted_zone_id}"
}
