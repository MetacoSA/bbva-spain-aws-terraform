terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.25.0"
    }
  }
}



provider "aws" {
  region = var.aws_region
}

locals {

}

module "vpc" {
  source = "./modules/vpc"
}

# resource "aws_vpc" "vpc_main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true
# }

# # Public Subnet
# resource "aws_subnet" "subnet_public" {
#   vpc_id                  = aws_vpc.vpc_main.id
#   cidr_block              = "10.0.0.0/24"
#   map_public_ip_on_launch = true
# }

# resource "aws_subnet" "subnet_private" {
#   vpc_id                  = aws_vpc.vpc_main.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
# }

# # Internet Gateway
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc_main.id
# }

# # NAT Gateway
# resource "aws_eip" "eip_nat_gw" {
# }

# resource "aws_nat_gateway" "nat_gw" {
#   allocation_id = aws_eip.eip_nat_gw.id
#   subnet_id     = aws_subnet.subnet_public.id
# }

# # Public Route Table
# resource "aws_route_table" "route_table_public" {
#   vpc_id = aws_vpc.vpc_main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
# }

# # Private Route Table
# resource "aws_route_table" "route_table_private" {
#   vpc_id = aws_vpc.vpc_main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gw.id
#   }
# }

# # Associate Route Tables with Subnets
# resource "aws_route_table_association" "public_association" {
#   subnet_id      = aws_subnet.subnet_public.id
#   route_table_id = aws_route_table.route_table_public.id
# }

# resource "aws_route_table_association" "private_association" {
#   subnet_id      = aws_subnet.subnet_private.id
#   route_table_id = aws_route_table.route_table_private.id
# }

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = module.vpc.vpc_id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name   = "private_sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}

data "aws_vpc" "aws_vpc_hmz_trusted_components" {
  # id = var.aws_vpc_id
  # id = aws_vpc.vpc_main.id
  id = module.vpc.vpc_id
}

data "aws_subnet" "hmz_trusted_components_subnet" {
  # id = var.aws_subnet_id
  # id = aws_subnet.subnet_public.id
  id = module.vpc.private_subnet_id
}

data "aws_security_group" "hmz_trusted_components_sg" {
  id = var.aws_security_group_id
}

resource "aws_security_group" "ecs_https_egress" {
  name        = "ecs_https_egress_sg"
  description = "Security group for ECS container to allow outbound HTTPS traffic"
  vpc_id      = data.aws_vpc.aws_vpc_hmz_trusted_components.id

  # Allow outbound HTTPS traffic on port 443
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"          # -1 means all protocols
    cidr_blocks      = ["0.0.0.0/0"] # 0.0.0.0/0 represents all IP addresses
    ipv6_cidr_blocks = ["::/0"]
  }
  # ingress {
  #   from_port        = 0
  #   to_port          = 0
  #   protocol         = "-1"          # -1 means all protocols
  #   cidr_blocks      = ["0.0.0.0/0"] # 0.0.0.0/0 represents all IP addresses
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  tags = {
    Name = "ECS HTTPS Egress"
  }
}


resource "aws_iam_role" "ecs_task_role_for_hmz_trusted_components" {
  name = "ecs_task_role_for_hmz_trusted_components"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_role_for_hmz_trusted_components.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${random_pet.random_name.id}-hmz-trusted-components-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "notary" {
  source = "./modules/notary"
  count  = var.hmz_notary_enabled ? 1 : 0

  random_pet = random_pet.random_name.id

  # AWS Config
  # aws_subnet_ids                 = [data.aws_subnet.hmz_trusted_components_subnet.id]
  aws_iam_role_ecs_task_role_arn     = aws_iam_role.ecs_task_role_for_hmz_trusted_components.arn
  aws_vpc_id                         = data.aws_vpc.aws_vpc_hmz_trusted_components.id
  aws_vpc_cidr                       = data.aws_vpc.aws_vpc_hmz_trusted_components.cidr_block
  aws_subnet_id                      = data.aws_subnet.hmz_trusted_components_subnet.id
  aws_cloud_watch_logs_group         = var.aws_cloud_watch_logs_group
  aws_cloud_watch_logs_stream_prefix = var.aws_cloud_watch_logs_stream_prefix
  aws_cloud_watch_logs_region        = var.aws_cloud_watch_logs_region
  aws_resource_tags                  = {}

  hmz_kms_oci_image                   = var.hmz_kms_oci_image
  hmz_kms_oci_tag                     = var.hmz_kms_oci_tag
  hmz_kms_container_registry_user     = coalesce(var.hmz_kms_container_registry_user, var.hmz_metaco_container_registry_user)
  hmz_kms_container_registry_password = coalesce(var.hmz_kms_container_registry_password, var.hmz_metaco_container_registry_password)

  hmz_notary_oci_image                   = var.hmz_notary_oci_image
  hmz_notary_oci_tag                     = var.hmz_notary_oci_tag
  hmz_notary_container_registry_user     = coalesce(var.hmz_notary_container_registry_user, var.hmz_metaco_container_registry_user)
  hmz_notary_container_registry_password = coalesce(var.hmz_notary_container_registry_password, var.hmz_metaco_container_registry_password)

  # Compulsory HMZ Notary environment variables
  hmz_notary_bridge_http_endpoint = var.hmz_notary_bridge_http_endpoint

  # Optional HMZ Notary environment variables
  hmz_notary_open_telemetry_type                = var.hmz_notary_open_telemetry_type
  hmz_notary_otel_sdk_disabled                  = var.hmz_notary_otel_sdk_disabled
  hmz_notary_hc_tracing_enabled                 = var.hmz_notary_hc_tracing_enabled
  hmz_notary_log_level                          = var.hmz_notary_log_level
  hmz_notary_grpc_enabled                       = var.hmz_notary_grpc_enabled
  hmz_notary_cols_dir                           = var.hmz_notary_cols_dir
  hmz_notary_kms_grpc_keep_alive_interval       = var.hmz_notary_kms_grpc_keep_alive_interval
  hmz_notary_kms_grpc_keep_alive_timeout        = var.hmz_notary_kms_grpc_keep_alive_timeout
  hmz_notary_state_manifest_file_path           = var.hmz_notary_state_manifest_file_path
  hmz_notary_state_manifest_signature_file_path = var.hmz_notary_state_manifest_signature_file_path

  # Compulsory HMZ KMS Connect environment variables
  hmz_kms_software_master_key = var.hmz_kms_software_master_key
}

resource "aws_ecs_service" "hmz_notary_ecs_service" {

  desired_count   = 1
  name            = "hmz-notary-ecs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = module.notary.0.ecs_task_definition.arn
  launch_type     = "FARGATE"

  network_configuration {
    # subnets = [var.aws_subnet_id]
    # security_groups = [data.aws_security_group.hmz_trusted_components_sg.id, aws_security_group.ecs_https_egress.id]
    # security_groups = [aws_security_group.ecs_https_egress.id]

    # subnets         = [aws_subnet.subnet_private.id]
    # security_groups = [aws_security_group.bastion_sg.id]

    subnets         = [module.vpc.private_subnet_id]
    security_groups = [aws_security_group.ecs_https_egress.id]
  }
}

module "vault" {
  source = "./modules/vault"

  for_each = {
    for index, vault in var.vaults :
    index => vault
  }

  random_pet = random_pet.random_name.id

  # AWS Config
  aws_iam_role_ecs_task_role_arn     = aws_iam_role.ecs_task_role_for_hmz_trusted_components.arn
  aws_vpc_id                         = data.aws_vpc.aws_vpc_hmz_trusted_components.id
  aws_vpc_cidr                       = data.aws_vpc.aws_vpc_hmz_trusted_components.cidr_block
  aws_subnet_id                      = data.aws_subnet.hmz_trusted_components_subnet.id
  aws_cloud_watch_logs_group         = var.aws_cloud_watch_logs_group
  aws_cloud_watch_logs_stream_prefix = var.aws_cloud_watch_logs_stream_prefix
  aws_cloud_watch_logs_region        = var.aws_cloud_watch_logs_region
  aws_resource_tags                  = {}

  hmz_kms_oci_image                   = var.hmz_kms_oci_image
  hmz_kms_oci_tag                     = var.hmz_kms_oci_tag
  hmz_kms_container_registry_user     = coalesce(var.hmz_kms_container_registry_user, var.hmz_metaco_container_registry_user)
  hmz_kms_container_registry_password = coalesce(var.hmz_kms_container_registry_password, var.hmz_metaco_container_registry_password)

  hmz_vault_oci_image                   = var.hmz_vault_oci_image
  hmz_vault_oci_tag                     = var.hmz_vault_oci_tag
  hmz_vault_container_registry_user     = coalesce(var.hmz_vault_container_registry_user, var.hmz_metaco_container_registry_user)
  hmz_vault_container_registry_password = coalesce(var.hmz_vault_container_registry_password, var.hmz_metaco_container_registry_password)

  // Same environment variables for all vaults
  hmz_vault_harmonize_core_endpoint = var.hmz_vault_harmonize_core_endpoint
  hmz_vault_trusted_sig             = var.hmz_vault_trusted_sig
  hmz_kms_software_master_key       = var.hmz_kms_software_master_key

  // Specific environment variables for each vault
  hmz_vault_id                     = each.value.hmz_vault_id
  hmz_vault_log_level              = each.value.hmz_vault_log_level
  hmz_vault_bridge_log_level       = each.value.hmz_vault_bridge_log_level
  hmz_vault_feature_otlp_in_stdout = each.value.hmz_vault_feature_otlp_in_stdout
}

resource "aws_ecs_service" "hmz_vault_ecs_service" {

  depends_on = [module.vault]

  for_each = {
    for index, vault in var.vaults :
    index => vault
  }

  desired_count   = 1
  name            = "hmz-vault-${each.value.hmz_vault_id}-ecs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = module.vault[each.key].ecs_task_definition.arn
  launch_type     = "FARGATE"

  network_configuration {
    # subnets = [var.aws_subnet_id]
    # security_groups = [data.aws_security_group.hmz_trusted_components_sg.id, aws_security_group.ecs_https_egress.id]
    # security_groups = [aws_security_group.ecs_https_egress.id]

    # subnets         = [aws_subnet.subnet_private.id]
    # security_groups = [aws_security_group.bastion_sg.id]

    subnets         = [module.vpc.private_subnet_id]
    security_groups = [aws_security_group.ecs_https_egress.id]
  }
}
