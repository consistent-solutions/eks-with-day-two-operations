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

# Node Group IAM policy (and attachment) for node cluster autoscaler
resource "aws_iam_policy" "eks-node-autoscale" {
  name        = "eks-node-autoscale"
  description = "Permissions for EKS Node Autoscaling."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "eks-node-autoscale" {
  role       = "${aws_iam_role.eks-node.name}"
  policy_arn = "${aws_iam_policy.eks-node-autoscale.arn}"
}

resource "aws_eks_node_group" "eks-node" {
  cluster_name    = "${var.eks_cluster_name}"
  node_group_name = "${var.env_name}-eks-node"
  node_role_arn   = "${aws_iam_role.eks-node.arn}"
  subnet_ids      = ["${var.subnet_ids}"]

  scaling_config {
    desired_size = "${var.eks_node_size}"
    max_size     = "${var.eks_node_max_count}"
    min_size     = "${var.eks_node_min_count}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly",
  ]

  tags = "${merge(var.default_tags, map(
      "Name", "${var.env_name}-eks-cluster",
      "k8s.io/cluster-autoscaler/${var.eks_cluster_name}", "owned",
      "k8s.io/cluster-autoscaler/enabled", "true"
    ))}"

}
