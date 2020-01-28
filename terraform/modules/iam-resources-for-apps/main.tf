
## Trust Policy used by all other roles to allow eks-node assume role
data "aws_iam_policy_document" trusts_policy {
  "statement" {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    principals {
      identifiers = ["${var.eks_node_iam_role_arn}"]
      type        = "AWS"
    }
  }
}


## External DNS
# Described via https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/aws.md#iam-permissions
data "aws_iam_policy_document" "external_dns_policy" {

  "statement" {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListTagsForResource"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${var.hosted_zone_id}",
    ]
  }

  "statement" {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = [
      "*",
    ]
  }

}


resource "aws_iam_policy" "external_dns_role_policy" {
  policy = "${data.aws_iam_policy_document.external_dns_policy.json}"
  name   = "${var.env_name}-external-dns"
}
resource "aws_iam_role_policy_attachment" "external_dns_attachment" {
  policy_arn = "${aws_iam_policy.external_dns_role_policy.arn}"
  role       = "${aws_iam_role.external_dns_role.name}"
}

resource "aws_iam_role" "external_dns_role" {
  name               = "${var.env_name}-external-dns"
  assume_role_policy = "${data.aws_iam_policy_document.trusts_policy.json}"
}


data "aws_iam_policy_document" "fluentd_cloudwatch_policy" {

  "statement" {
    effect = "Allow"
    actions = [
      "logs:*"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}


resource "aws_iam_policy" "fluentd_cloudwatch_role_policy" {
  policy = "${data.aws_iam_policy_document.fluentd_cloudwatch_policy.json}"
  name   = "${var.env_name}-fluentd-cloudwatch"
}
resource "aws_iam_role_policy_attachment" "fluentd_cloudwatch_attachment" {
  policy_arn = "${aws_iam_policy.fluentd_cloudwatch_role_policy.arn}"
  role       = "${aws_iam_role.fluentd_cloudwatch_role.name}"
}

resource "aws_iam_role" "fluentd_cloudwatch_role" {
  name               = "${var.env_name}-fluentd-cloudwatch"
  assume_role_policy = "${data.aws_iam_policy_document.trusts_policy.json}"
}




data "aws_iam_policy_document" "velero_policy" {

  "statement" {
    effect = "Allow"
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot"
    ]

    resources = [
      "*",
    ]
  }

  "statement" {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.velero_bucket_name}"
    ]
  }

  "statement" {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]

    resources = [
      "arn:aws:s3:::${var.velero_bucket_name}/*"
    ]
  }

}


resource "aws_iam_policy" "velero_role_policy" {
  policy = "${data.aws_iam_policy_document.velero_policy.json}"
  name   = "${var.env_name}-velero"
}
resource "aws_iam_role_policy_attachment" "velero_attachment" {
  policy_arn = "${aws_iam_policy.velero_role_policy.arn}"
  role       = "${aws_iam_role.velero_role.name}"
}

resource "aws_iam_role" "velero_role" {
  name               = "${var.env_name}-velero"
  assume_role_policy = "${data.aws_iam_policy_document.trusts_policy.json}"
}



data "aws_iam_policy_document" "alb_ingress_controller_policy" {

  "statement" {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]

    resources = [
      "*",
    ]
  }

  "statement" {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = [
      "*",
    ]
  }

    "statement" {
      effect = "Allow"
      actions = [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ]

      resources = [
        "*",
      ]
    }

    "statement" {
      effect = "Allow"
      actions = [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ]

      resources = [
        "*",
      ]
    }

    "statement" {
      effect = "Allow"
      actions = [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ]

      resources = [
        "*",
      ]
    }

    "statement" {
      effect = "Allow"
      actions = [
        "tag:GetResources",
        "tag:TagResources"
      ]

      resources = [
        "*",
      ]
    }

    "statement" {
      effect = "Allow"
      actions = [
        "waf:GetWebACL"
      ]

      resources = [
        "*",
      ]
    }

    "statement" {
      effect = "Allow"
      actions = [
        "cognito-idp:DescribeUserPoolClient"
      ]
      resources = [
        "*",
      ]
    }
}

resource "aws_iam_policy" "alb_ingress_controller_role_policy" {
  policy = "${data.aws_iam_policy_document.alb_ingress_controller_policy.json}"
  name   = "${var.env_name}-alb-ingress-controller"
}
resource "aws_iam_role_policy_attachment" "alb_ingress_controller_attachment" {
  policy_arn = "${aws_iam_policy.alb_ingress_controller_role_policy.arn}"
  role       = "${aws_iam_role.alb_ingress_controller_role.name}"
}

resource "aws_iam_role" "alb_ingress_controller_role" {
  name               = "${var.env_name}-alb-ingress-controller"
  assume_role_policy = "${data.aws_iam_policy_document.trusts_policy.json}"
}
