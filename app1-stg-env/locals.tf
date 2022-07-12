/*
This file is managed by AWS Proton. Any changes made directly to this file will be overwritten the next time AWS Proton performs an update.

To manage this resource, see AWS Proton Resource: arn:aws:proton:ap-northeast-1:027500179340:environment/app1-stg-env

If the resource is no longer accessible within AWS Proton, it may have been deleted and may require manual cleanup.
*/

resource "random_id" "this" {
  byte_length = 2
}

locals {
  tenant      = "aws001"  # AWS account name or unique id for tenant
  environment = "preprod" # Environment area eg., preprod or prod
  zone        = "dev"     # Environment with in one sub_tenant or business unit

  eks_cluster_version = var.environment.inputs.kubernetes_version
  cluster_name        = var.environment.inputs.cluster_name
  eks_cluster_id      = "${random_id.this.hex}-${local.cluster_name}"

  vpc_cidr = var.environment.inputs.vpc_cidr
  vpc_name = var.environment.inputs.cluster_name
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  managed_node_groups = {
    mng = {
      node_group_name = "${local.eks_cluster_id}-mng"
      instance_types  = ["m5.xlarge"]
      subnet_ids      = module.aws_vpc.private_subnets
      desired_size    = 3
      max_size        = 3
      min_size        = 3
    }
  }

  #---------------------------------------------------------------
  # TEAMS
  #---------------------------------------------------------------
  platform_teams = {
    platform-team = {
      users = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.environment.inputs.user}"]
    }
  }

  #----------------------------------------------------------------
  # ADD ONs
  #----------------------------------------------------------------

  amazon_eks_vpc_cni_config = {
    addon_name               = "vpc-cni"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }

  amazon_eks_coredns_config = {
    addon_name               = "coredns"
    addon_version            = data.aws_eks_addon_version.coredns.version
    service_account          = "coredns"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }

  amazon_eks_kube_proxy_config = {
    addon_name               = "kube-proxy"
    addon_version            = data.aws_eks_addon_version.kube_proxy.version
    service_account          = "kube-proxy"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path               = "chart"
    repo_url           = "https://github.com/flask-mario/eks-blueprints-add-ons.git"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path               = "envs/dev"
    repo_url           = "https://github.com/flask-mario/eks-blueprints-workloads.git"
    add_on_application = false
  }


}