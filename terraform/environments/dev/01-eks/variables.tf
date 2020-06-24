#Global Vars

variable "env_name" {
  default = "dev"
}

variable "default_tags" {
  default = {
    environment = "dev"
  }
}

variable "eks_node_size" {
  default = "2"
}

variable "eks_node_min" {
  default = "2"
}

variable "eks_node_max" {
  default = "5"
}

variable "eks_version" {
  default = "1.14"
}

#VPC Vars
#note using vpc module from kubespray
variable "aws_vpc_cidr_block" {
  default = "10.250.192.0/18"
}

variable "aws_avail_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "aws_cidr_subnets_private" {
  default = ["10.250.192.0/20", "10.250.208.0/20"]
}

variable "aws_cidr_subnets_public" {
  default = ["10.250.224.0/20", "10.250.240.0/20"]
}

# variables for iam-resources-for-apps
variable "hosted_zone_id" {
  default = "Z32U1A70WQFBB1"
}

## workstation vars
##
variable "aws_workstation_vol_size" {
  default = "20"
}

variable "aws_workstation_instance_type" {
  default = "t2.medium"
}

# NOTE: hardcoding this for now!
# SEE module vars for the ami filter
# ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20190913 - ami-04763b3055de4860b
variable "aws_workstation_ami" {
  default = "ami-04763b3055de4860b"
}

variable "aws_workstation_count" {
  default = "1"
}
