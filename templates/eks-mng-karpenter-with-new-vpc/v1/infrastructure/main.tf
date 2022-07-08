#---------------------------------------------------------------
# Consume EKS Blueprints module
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.0.4"

  # ENV Tags
  tenant      = "${random_id.this.hex}-${local.tenant}"
  environment = local.environment
  zone        = local.zone

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.eks_cluster_version
  cluster_name    = local.eks_cluster_id

  # EKS MANAGED NODE GROUPS
  managed_node_groups = local.managed_node_groups

  # Teams
  platform_teams = local.platform_teams
}

#-------------------------------------------------------------------
# Consume eks-blueprints/kubernetes-addons module
#-------------------------------------------------------------------

module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.0.4"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # EKS Managed Add-ons
  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = local.amazon_eks_coredns_config

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = local.amazon_eks_kube_proxy_config

  # K8s Add-ons
  enable_aws_for_fluentbit            = true
  enable_aws_load_balancer_controller = true
  enable_cert_manager                 = true
  enable_karpenter                    = true
  enable_metrics_server               = true
  enable_vpa                          = true

  depends_on = [module.eks_blueprints.managed_node_groups]
}

