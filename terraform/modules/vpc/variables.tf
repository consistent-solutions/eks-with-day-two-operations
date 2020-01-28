variable "aws_vpc_cidr_block" {
  description = "CIDR Blocks for AWS VPC"
}

variable "env_name" {
  description = "Name of Cluster"
}

variable "aws_avail_zones" {
  description = "AWS Availability Zones Used"
  type        = "list"
}

variable "aws_cidr_subnets_private" {
  description = "CIDR Blocks for private subnets in Availability zones"
  type        = "list"
}

variable "aws_cidr_subnets_public" {
  description = "CIDR Blocks for public subnets in Availability zones"
  type        = "list"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = "map"
}

# specific bastion vars
variable "aws_bastion_ssh_key_name" {
  description = "ssh key for bastion"
}

variable "aws_bastion_vol_size" {
  description = "bastion volume size"
}

variable "aws_bastion_instance_type" {
  description = "instance type of bastion"
}

variable "aws_bastion_ami" {
  description = "ami id for bastion"
  default        = "ami-04763b3055de4860b"
}

#NOTE feel free to leverage the filter. Be sure to update the ami main.tf
data "aws_ami" "distro" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

variable "aws_bastion_count" {
  description = "number of bastions"
  default = "1"
}
