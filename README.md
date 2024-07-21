### next-site-demo

Documentation below will provide answers to the tasks from "Challenge 3":

```
# Challenge 3: Website Deployment

Welcome to Challenge 3.

This project was bootstrapped with [Create Next App](https://nextjs.org/docs/pages/api-reference/create-next-app).

## Task 1 

Given this project deploy it to AWS in an automated and reproducible fashion. The website should be reachable from all over the world.

## Task 2 

Restrict access to the site by using mechanisms that can be adapted programmatically.

## Task 3 

Deploy the site using at least 2 technology stacks. Make sure that both types of deployment can be reproduced in an automated fashion.

## Task 4 

What issues can you identify in the given site? What types of improvements would you suggest?
```

### DISCLAIMER!

All solution presented below are simplified and are valid only for demo or development purposes. 
Terraform code in this repo is also simplified.

#### Git repository setup

In repository next-site-demo we have three branches:

* main
* dev
* dev-static

`main` branch contains this documentation and necessary terraform code. 

`dev` Using this branch and appropriate github we will build docker container and deploy it on AWS environment

`dev-static` Using this branch and appropriate github we will build static website export and push it to AWS S3 bucket

Git repository uses self-hosted runner for Github Actions execution. Runner is deployed in AWS on EC2 instance with attached appropriate IAM Role. This roles has following permissions:

* Upload/Update/Delete object on S3 bucket
* Push docker image to ECR repository
* Update ECS service

#### Exposing website to the world

All websites are exposed via Cloudflare. 

#### Terraform code

##### S3 bucket definition

`terraform/aws/storage/s3_static.tf`

##### ECS Fargate definition

`terraform/aws/ecs/`


#### Task 1 and Task 3

##### `dev` branch

Github Actions are defined in

`.github/workflows/build-docker-container.yaml`

This action:

1. installs npm/node and all required dependencies for NextJS. 
2. configures AWS ECR access
3. builds docker image (with Dockerfile)
4. pushes image to ECR
5. restarts ECS Fargate service (this step has been added after first initial successful deployment of the container to AWS Fargate)

Infrastructure necessary to run this docker image is defined in `terraform/aws/ecs/` in `main` branch. Terraform code creates:
1. ECS Fargate Cluster
2. EC2 Application Load Balancer
3. ALB target groups
4. ECS service using container from AWS ECR private repository

Website is reachable via following address:

[https://next-docker.deploy.ninja](https://next-docker.deploy.ninja)

###### Additional comments
For production environment, steps from github action should be separated into multiple, reviewable steps. 
1. Build stage
2. Build dev version of the container
3. Approve and deploy dev version
4. Run test on dev version
5. Build production version of the container
6. Approve and deploy production version


##### `dev-static` branch

Github Actions are defined in

`.github/workflows/build-static.yaml`

This action:

1. installs npm/node and all required dependencies for NextJS. 
2. builds static website export
3. copies static site to S3 bucket

Website is reachable via following address:

[https://static-site.deploy.ninja](https://static-site.deploy.ninja)

#### Task 2

The simplest approach that allows implementation of site access controls is to use correct definition in AWS security group for load balancer:

```
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.11.0.0/16"
    }
  }
```


This way we can control access to this website via terraform code

Another approach (also with terraform) is to setup appropriate S3 bucket policy or Cloudflare WAF rules:


```
statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::static-S3-bucket",
      "arn:aws:s3:::static-S3-bucket/*"
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
			...
      ]
    }
```

#### Task 4

Website requires some security fixes. It uses deprecated `axios` module with critical vulnerability. 

In order to fix it, we have to update `package.json` with a correct version of `axios` module:

```
{
  "name": "challenge3",
  "scripts": {
    "dev": "next",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "axios": "^1.7.2",
    "next": "^14.2.5",
    "prop-types": "15.8.1",
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  }
``` 

