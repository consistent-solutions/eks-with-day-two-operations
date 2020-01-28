#Global Vars

variable "env_name" {
  default = "dev"
}

variable "default_tags" {
  default = {
    environment = "dev"
  }
}

#VPC Vars
#note using vpc module influenced from kubespray
variable "aws_vpc_cidr_block" {
  default = "10.250.0.0/16"
}

variable "aws_avail_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "aws_cidr_subnets_private" {
  default = ["10.250.6.0/24","10.250.7.0/24", "10.250.8.0/24"]
}

variable "aws_cidr_subnets_public" {
  default = ["10.250.9.0/24", "10.250.10.0/24", "10.250.11.0/24"]
}

## bastion vars
# specific bastion vars
variable "aws_ssh_key_name" {
  default = "cs-win-east-1-getsome"
}

variable "aws_bastion_vol_size" {
  default = "50"
}

variable "aws_bastion_instance_type" {
  default = "t2.medium"
}

variable "aws_bastion_count" {
  description = "number of bastions"
  default = "1"
}


# SEE module vars for leveraging ami filter
# NOTE: hardcoding this for now!
# ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20190913 - ami-04763b3055de4860b
variable "aws_bastion_ami" {
  default = "ami-04763b3055de4860b"
}


# s3 vars
variable "velero_bucket_name" {
  default = "consistentsolutions-dev-velero"
}
