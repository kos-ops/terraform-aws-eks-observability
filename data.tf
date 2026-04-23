data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id
  oidc_id    = trimprefix(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://")
}
