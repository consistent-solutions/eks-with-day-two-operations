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


resource "aws_eks_fargate_profile" "fargate-example" {
  cluster_name           = "${module.eks-cluster.eks_cluster_name}"
  fargate_profile_name   = "${var.env_name}-fargate-profile"
  pod_execution_role_arn = "${aws_iam_role.fargate_pod_execution_role.arn}"
  subnet_ids             = ["${data.terraform_remote_state.00-base-infra.aws_subnet_ids_private}"]

  selector {
    namespace = "fargate-ns"

    #labels = { scheduler = "fargate" }
  }

  depends_on = [
    "aws_iam_role_policy_attachment.example-AmazonEKSFargatePodExecutionRolePolicy"
  ]
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = "${aws_iam_role.fargate_pod_execution_role.name}"
}

resource "aws_iam_role" "fargate_pod_execution_role" {
  name = "${var.env_name}-eks-fargate-pod-execution-role"
  #force_detach_policies = true

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
           "eks.amazonaws.com",
           "eks-fargate-pods.amazonaws.com"
           ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}
