variable "env_name" {
  description = "env name"
}

variable "eks_cluster_name" {
  description = "name of eks cluster"
}

variable "eks_cluster_version" {
  description = "version of eks cluster"
}

#NOTE: this is a role created outside of this tf.
variable "workstation_instance_profile_name" {
  default = "tf-privileged"
}
variable "vpc_id" {
  description = "id of vpc"
}

variable "subnet_id" {
  description = "id of the subnet where the workstations will reside"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = "map"
}

variable "workstation_ami" {
  description = "ami id for workstation"
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

variable "aws_workstation_instance_type" {
  description = "instance type of workstation"
}

variable "aws_workstation_count" {
  description = "number of workstations"
}

variable "eks_cluster_sg_id" {
  description = "id of eks sg to add to workstation"
}

variable "aws_workstation_ssh_key_name" {
  description = "ssh key for workstation"
}

variable "aws_workstation_vol_size" {
  description = "volume size of ebs on the workstation"
}
