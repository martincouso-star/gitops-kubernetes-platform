locals {
  external_dns_namespace_sa = "external-dns:external-dns"
  cert_manager_namespace_sa = "cert-manager:cert-manager"
  ebs_csi_namespace_sa      = "kube-system:ebs-csi-controller-sa"
}

module "external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.8.2"

  name                          = "${var.cluster_name}-external-dns"
  policy_name                   = "${var.cluster_name}-external-dns"
  use_name_prefix               = false
  description                   = "IRSA for external-dns in ${var.cluster_name}."
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = var.route53_zone_arns

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = [local.external_dns_namespace_sa]
    }
  }

  tags = var.tags
}

module "cert_manager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.8.2"

  name                          = "${var.cluster_name}-cert-manager"
  policy_name                   = "${var.cluster_name}-cert-manager"
  use_name_prefix               = false
  description                   = "IRSA for cert-manager DNS-01 in ${var.cluster_name}."
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = var.route53_zone_arns

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = [local.cert_manager_namespace_sa]
    }
  }

  tags = var.tags
}

module "ebs_csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.8.2"

  name                  = "${var.cluster_name}-ebs-csi"
  policy_name           = "${var.cluster_name}-ebs-csi"
  use_name_prefix       = false
  description           = "IRSA for the EBS CSI controller in ${var.cluster_name}."
  attach_ebs_csi_policy = true

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = [local.ebs_csi_namespace_sa]
    }
  }

  tags = var.tags
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  service_account_role_arn    = module.ebs_csi.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags
}
