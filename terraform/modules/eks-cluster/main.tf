
resource "aws_iam_role" "eks-cluster" {
  name = "${var.env_name}-eks-cluster"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_security_group" "eks-cluster" {
  name        = "${var.env_name}-eks-cluster"
  description = "communicate with nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = "${merge(var.default_tags, map(
      "Name", "${var.env_name}-eks-cluster"
    ))}"
}


resource "aws_security_group_rule" "allow-ingress-itself" {
  self              = true
  description       = "self rule allow all"
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 0
  type              = "ingress"
}


data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

resource "aws_security_group_rule" "ingress-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  #cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.env_name}-eks-cluster"
  role_arn = "${aws_iam_role.eks-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = ["${var.subnet_ids}"] # have these be private

    endpoint_private_access = true
    endpoint_public_access = "${var.endpoint_public_access}"
  }
  version = "${var.eks_version}"
  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
  ]

  tags = "${merge(var.default_tags, map(
      "Name", "${var.env_name}-eks-cluster"
    ))}"

}
