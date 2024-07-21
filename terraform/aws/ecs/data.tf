#data.aws_ssm_parameter.ghapp_key.value

data "aws_caller_identity" "current" {
    provider = aws.infra
}

data "aws_region" "current" {
    provider = aws.infra
}

data "aws_elb_service_account" "current" {
    provider = aws.infra
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }

  provider = aws.network
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*private*"
  }

  provider = aws.network

}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*public*"
  }

  provider = aws.network

}
