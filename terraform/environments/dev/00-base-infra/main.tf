terraform {
  required_version = "= 0.11.2"

  backend "s3" {
    bucket = "cs-eks-example-solution"
    key    = "dev/00-base-infra.tf"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "s3_velero" {
  source = "../../../modules/s3"

  bucket_name = "${var.velero_bucket_name}"
}

module "vpc" {
  source = "../../../modules/vpc"

  env_name                  = "${var.env_name}"
  default_tags              = "${var.default_tags}"
  aws_vpc_cidr_block        = "${var.aws_vpc_cidr_block}"
  aws_avail_zones           = "${var.aws_avail_zones}"
  aws_cidr_subnets_private  = "${var.aws_cidr_subnets_private}"
  aws_cidr_subnets_public   = "${var.aws_cidr_subnets_public}"
  aws_bastion_ssh_key_name  = "${var.aws_ssh_key_name}"
  aws_bastion_vol_size      = "${var.aws_bastion_vol_size}"
  aws_bastion_instance_type = "${var.aws_bastion_instance_type}"
  aws_bastion_count         = "${var.aws_bastion_count}"
  aws_bastion_ami           = "${var.aws_bastion_ami}"

}
