resource "aws_iam_role" "eks-node" {
  name = "${var.env_name}-eks-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_eks_node_group" "eks-node" {
  cluster_name    = "${var.eks_cluster_name}"
  node_group_name = "${var.env_name}-eks-node"
  node_role_arn   = "${aws_iam_role.eks-node.arn}"
  subnet_ids      = ["${var.subnet_ids}"]

  scaling_config {
    desired_size = "${var.eks_node_size}"
    max_size     = "${var.eks_node_size}"
    min_size     = "${var.eks_node_size}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly",
  ]

  tags = "${merge(var.default_tags, map(
      "Name", "${var.env_name}-eks-cluster"
    ))}"

}
