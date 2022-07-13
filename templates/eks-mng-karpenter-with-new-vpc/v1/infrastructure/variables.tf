variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "tenant" {
  type    = string
  default = "non-argo"  # AWS account name or unique id for tenant
}

variable "environment" {
  type    = string
  default = "preprod" # Environment area eg., preprod or prod
}

variable "zone" {
  type    = string
  default = "dev"     # Environment with in one sub_tenant or business unit
}

variable "eks_cluster_version" {
  type    = string
  default = "1.20"
}

variable "vpc_cidr" {
  type = string
  default = "10.10.0.0/16"
}

