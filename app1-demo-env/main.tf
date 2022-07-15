/*
This file is no longer managed by AWS Proton. The associated resource has been deleted in Proton.
*/

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

module "aws_controllers" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.0.4/modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  #---------------------------------------------------------------
  # Use AWS controllers separately
  # So that it can delete ressources it created from other addons or workloads
  #---------------------------------------------------------------

  enable_aws_load_balancer_controller = true
  enable_karpenter                    = false
  enable_aws_for_fluentbit            = false

  depends_on = [module.eks_blueprints.managed_node_groups]
}

#-------------------------------------------------------------------
# Consume eks-blueprints/kubernetes-addons module
#-------------------------------------------------------------------

module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.0.7/modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.
  argocd_applications = {
    addons    = local.addon_application
    workloads = local.workload_application
  }

  argocd_helm_config = {
    values = [templatefile("${path.module}/argocd-values.yaml", {})]
  }

  #---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_aws_for_fluentbit            = var.environment.inputs.aws_for_fluentbit
  enable_cert_manager                 = false
  enable_cluster_autoscaler           = false
  enable_ingress_nginx                = var.environment.inputs.ingress_nginx
  enable_keda                         = false
  enable_metrics_server               = false
  enable_prometheus                   = false
  enable_traefik                      = false
  enable_vpa                          = false
  enable_yunikorn                     = false
  enable_argo_rollouts                = false

  # EKS Managed Add-ons
  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = local.amazon_eks_coredns_config
  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = local.amazon_eks_kube_proxy_config

  depends_on = [module.eks_blueprints.managed_node_groups, module.aws_controllers]
}

