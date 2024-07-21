locals {
  euc1-tools-role-name  = "infra-ec2-tools-role"
  euc1-static-s3        = "next-static.deploy.ninja"

}

data "aws_iam_policy_document" "euc1_static_s3_access_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [
      "arn:aws:s3:::${local.euc1-static-s3}"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.euc1-tools-role.arn]
    }
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::${local.euc1-static-s3}",
      "arn:aws:s3:::${local.euc1-static-s3}/*"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.euc1-tools-role.arn]
    }
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${local.euc1-static-s3}",
      "arn:aws:s3:::${local.euc1-static-s3}/*"
    ]
    effect = "Deny"
    principals { 
      type        = "AWS"
      identifiers = ["*"]
    }

   condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"

      values = [
        "173.245.48.0/20",
        "103.21.244.0/22",
        "103.22.200.0/22",
        "103.31.4.0/22",
        "141.101.64.0/18",
        "108.162.192.0/18",
        "190.93.240.0/20",
        "188.114.96.0/20",
        "197.234.240.0/22",
        "198.41.128.0/17",
        "162.158.0.0/15",
        "104.16.0.0/13",
        "104.24.0.0/14",
        "172.64.0.0/13",
        "131.0.72.0/22",
        "2400:cb00::/32",
        "2606:4700::/32",
        "2803:f800::/32",
        "2405:b500::/32",
        "2405:8100::/32",
        "2a06:98c0::/29",
        "2c0f:f248::/32"
      ]
    }

  }

}


module "s3-eu-central-1-static" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "next-static.deploy.ninja"

  restrict_public_buckets               = false
  block_public_acls                     = false
  block_public_policy                   = false
  ignore_public_acls                    = false
  attach_deny_insecure_transport_policy = false

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
      }
    }
  }

  attach_policy = true
  policy = data.aws_iam_policy_document.euc1_static_s3_access_policy.json

  versioning = {
    enabled = true
  }

  providers = {
     aws = aws.infra
  }

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  force_destroy = true

}
