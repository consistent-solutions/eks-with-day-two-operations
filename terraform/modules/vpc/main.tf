resource "aws_vpc" "cluster-vpc" {
  cidr_block = "${var.aws_vpc_cidr_block}"

  #DNS Related Entries
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${merge(var.default_tags, map(
      "Name", "kubernetes-${var.env_name}-vpc"
    ))}"
}

resource "aws_eip" "cluster-nat-eip" {
  count = "${length(var.aws_cidr_subnets_public)}"
  vpc   = true
}

resource "aws_internet_gateway" "cluster-vpc-internetgw" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  tags = "${merge(var.default_tags, map(
    "Name", "kubernetes-${var.env_name}-internetgw"
  ))}"
}

resource "aws_subnet" "cluster-vpc-subnets-public" {
  vpc_id            = "${aws_vpc.cluster-vpc.id}"
  count             = "${length(var.aws_avail_zones)}"
  availability_zone = "${element(var.aws_avail_zones, count.index)}"
  cidr_block        = "${element(var.aws_cidr_subnets_public, count.index)}"

  tags = "${merge(var.default_tags, map(
      "Name", "kubernetes-${var.env_name}-${element(var.aws_avail_zones, count.index)}-public",
      "kubernetes.io/cluster/${var.env_name}", "member",
      "kubernetes.io/role/elb", "1"
    ))}"
}

resource "aws_nat_gateway" "cluster-nat-gateway" {
  count         = "${length(var.aws_cidr_subnets_public)}"
  allocation_id = "${element(aws_eip.cluster-nat-eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.cluster-vpc-subnets-public.*.id, count.index)}"
}

resource "aws_subnet" "cluster-vpc-subnets-private" {
  vpc_id            = "${aws_vpc.cluster-vpc.id}"
  count             = "${length(var.aws_avail_zones)}"
  availability_zone = "${element(var.aws_avail_zones, count.index)}"
  cidr_block        = "${element(var.aws_cidr_subnets_private, count.index)}"

  tags = "${merge(var.default_tags, map(
      "Name", "kubernetes-${var.env_name}-${element(var.aws_avail_zones, count.index)}-private"
    ))}"
}

#Routing in VPC

resource "aws_route_table" "kubernetes-public" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cluster-vpc-internetgw.id}"
  }

  tags = "${merge(var.default_tags, map(
      "Name", "kubernetes-${var.env_name}-routetable-public"
    ))}"
}

resource "aws_route_table" "kubernetes-private" {
  count  = "${length(var.aws_cidr_subnets_private)}"
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.cluster-nat-gateway.*.id, count.index)}"
  }

  tags = "${merge(var.default_tags, map(
      "Name", "kubernetes-${var.env_name}-routetable-private-${count.index}"
    ))}"
}

resource "aws_route_table_association" "kubernetes-public" {
  count          = "${length(var.aws_cidr_subnets_public)}"
  subnet_id      = "${element(aws_subnet.cluster-vpc-subnets-public.*.id,count.index)}"
  route_table_id = "${aws_route_table.kubernetes-public.id}"
}

resource "aws_route_table_association" "kubernetes-private" {
  count          = "${length(var.aws_cidr_subnets_private)}"
  subnet_id      = "${element(aws_subnet.cluster-vpc-subnets-private.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.kubernetes-private.*.id,count.index)}"
}

resource "aws_security_group" "bastion" {
  name        = "${var.env_name}-bastion"
  description = "ssh with bastions"
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "ingress-ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ingress ssh"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  to_port           = 22
  type              = "ingress"
}

resource "aws_instance" "bastion-server" {
  # ami                         = "${data.aws_ami.distro.id}"
  ami                         = "${var.aws_bastion_ami}"
  instance_type               = "${var.aws_bastion_instance_type}"
  count                       = "${var.aws_bastion_count}"
  #count                       = "${length(var.aws_cidr_subnets_public)}"
  subnet_id                   = "${element(aws_subnet.cluster-vpc-subnets-public.*.id,count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  key_name = "${var.aws_bastion_ssh_key_name}"

  tags = "${merge(var.default_tags, map(
      "Name", "${var.env_name}-bastion-${count.index}"
    ))}"

  root_block_device {
    volume_size = "${var.aws_bastion_vol_size}"
  }
}
