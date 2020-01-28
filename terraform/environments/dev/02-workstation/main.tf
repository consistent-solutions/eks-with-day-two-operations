terraform {
  required_version = "= 0.11.2"

  backend "s3" {
    bucket = "cs-eks-example-solution"
    key    = "dev/02-workstation.tf"
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


data "terraform_remote_state" "01-eks" {
  backend = "s3"

  config {
    bucket = "cs-eks-example-solution"
    key    = "dev/01-eks.tf"
    region = "us-east-1"
  }
}


module "workstation" {
  source = "../../../modules/workstation"

  env_name                       = "${var.env_name}"
  vpc_id                         = "${data.terraform_remote_state.00-base-infra.aws_vpc_id}"
  subnet_id                      = "${data.terraform_remote_state.00-base-infra.aws_subnet_ids_public[0]}"
  default_tags                   = "${var.default_tags}"
  aws_workstation_instance_type  = "${var.aws_workstation_instance_type}"
  aws_workstation_count          = "${var.aws_workstation_count}"
  eks_cluster_sg_id              = "${data.terraform_remote_state.01-eks.eks_cluster_sg_id}"
  aws_workstation_ssh_key_name   = "${var.aws_ssh_key_name}"
  aws_workstation_vol_size       = "${var.aws_workstation_vol_size}"
  eks_cluster_name               = "${data.terraform_remote_state.01-eks.eks_cluster_name}"
  eks_cluster_version            = "${var.eks_cluster_version}"
}
