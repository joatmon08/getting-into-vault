module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = var.name
  cluster_version = "1.26"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    create_iam_role = true
    ami_type        = "AL2_x86_64"
    disk_size       = 100
    instance_types  = ["m5.large"]
  }

  eks_managed_node_groups = {
    default = {
      use_custom_launch_template = false

      min_size     = 1
      max_size     = 5
      desired_size = 3

      instance_types = ["m5.large"]
    }
  }

  cluster_security_group_additional_rules = {
    vault_servers = {
      description = "Allow Vault servers to access Kubernetes cluster"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
}