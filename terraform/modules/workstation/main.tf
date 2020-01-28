###########
#### ADD WORKSTATION IN VPC FOR NOW to work with cluster w/o publicly exposing API ENDPOINT
resource "aws_security_group" "workstation" {
  name        = "${var.env_name}-workstation"
  description = "ssh with workstation"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.workstation.id}"
  to_port           = 22
  type              = "ingress"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.sh.tpl")}"
  vars = {
    eks_cluster_name = "${var.eks_cluster_name}"
    eks_cluster_version = "${var.eks_cluster_version}"
  }
}

data "aws_eks_cluster" "eks" {
  name = "${var.eks_cluster_name}"
}

resource "aws_instance" "workstation" {
  #ami                         = "${data.aws_ami.distro.id}"
  ami                         = "${var.workstation_ami}"
  instance_type               = "${var.aws_workstation_instance_type}"

  count                       = "${var.aws_workstation_count}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.workstation.id}","${data.aws_eks_cluster.eks.vpc_config.0.cluster_security_group_id}"]

  #NOTE: the version is assumed for the kubectl
  user_data = "${data.template_file.userdata.rendered}"

  iam_instance_profile = "${var.workstation_instance_profile_name}"

  key_name = "${var.aws_workstation_ssh_key_name}"

  tags = "${merge(var.default_tags, map(
      "Name", "${var.env_name}-workstation-${count.index}"
    ))}"

  root_block_device {
    volume_size = "${var.aws_workstation_vol_size}"
  }
}
