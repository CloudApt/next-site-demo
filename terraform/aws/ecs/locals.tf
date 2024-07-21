data "aws_availability_zones" "available" {
  provider = aws.infra
}

locals {
  region    = "eu-central-1"
  name      = "next-site"

  vpc_name  = "vpc-eu-central-1-infra"

  azs       = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "next-site"
  container_port = 3000

}
