/**
 * # Metaco Harmonize Trusted Components Terraform Scripts for AWS ECS
 * 
 * This project simplifies the creation and update of AWS ECS over Fargate,
 * hosting Harmonize Trusted Components with a software HMZ KMS provider.
 * 
 * Request information to our Customer success team to become familiar with
 * the software HMZ KMS provider.
 * 
 * ## Required Dependencies
 * 
 * To get started, install all required dependencies on the host machine.
 * 
 * ### Check versions
 * 
 * To check `terraform` version, run `terraform version`:
 * 
 * Example output:
 * 
 * ```bash
 * Terraform v1.6.3
 * on darwin_arm64
 * + provider registry.terraform.io/hashicorp/aws v5.26.0
 * + provider registry.terraform.io/hashicorp/random v2.3.2
 * ```
 *
 * Initialize the Terraform scripts:
 *
 * ```bash
 * terraform init
 * ```
 *
 * ### Local configuration
 *
 * The Terraform scripts uses two configuration files:
 *
 * - `.env` file (for AWS Credentials)
 * - `tfvars.terraform` file (for deployment parameters) 
 *
 * Copy the provided sample configuration files
 *  
 * ```bash
 * cp .env.sample .env
 * cp terraform.tfvars.sample terraform.tfvars
 * ```
 *
 * ### AWS Credentials 
 *
 *
 * Fill the environment variables file with you AWS Account credentials
 * 
 * ```bash
 * export AWS_ACCESS_KEY_ID='<YOUR_AWS_ACCESS_KEY>'
 * export AWS_SECRET_ACCESS_KEY='<YOUR_AWS_ACCESS_KEY>'
 * ```
 *
 * The [official AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) provide detailed steps to create an AWS Access Key.
 * An AWS Access Key can be created for the root user by [following this documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user_manage_add-key.html).
 *
 * ### Metaco Container Registry Credentials
 *
 * Retrieve the provided Metaco Container Registry Credentials (user and password) and fill the `tfvars.terraform` file.
 *
 * ### Harmonize Version
 *
 * The OCI (Open Container Initiative) tags MUST be provided in the file `tfvars.terraform` for the following HMZ Trusted Components:
 *
 * - Harmonize KMS Connect 
 * - Harmonize Notary
 * - Harmonize Vault
 *
 * ### Harmonize SaaS instance endpoints
 *
 * Retrieve the provided dedicated Harmonize endpoint:
 *
 * - Harmonize Core API endpoint (for the Vault)
 * - Harmonize Notary Bridge endpoint (for the Notary)
 *
 * The `tfvars.terraform` file MUST be filled with those values.
 *
 * ### Harmonize Vault Config
 * 
 * For each Harmonize Vault instance, fill the values:
 *
 * - Vault ID
 * - Vault Log Level
 * - Vault Bridge Log Level
 * - Vault Trusted Notary Messaging Public Key (retrieved after Genesis is executed successfully)
 *
 * #### Notary Message Public Key retrieval
 *
 * First apply the Genesis against the Harmonize API (HTTP POST request @ /v1/genesis)
 *
 * ```bash
 * curl -s \
 *     --location -g \
 *     --request POST "$HMZ_URL_API/v1/genesis" \
 *     --header 'Content-Type: application/json' \
 *     --data @"$FILE_NAME_GENESIS_CONFIG_JSON"
 * ```
 *
 * Then, after a successful Genesis application, fetch from the Harmonize API,
 * the Notary Messaging Public Key:
 *
 * ```bash
 * curl \
 *     --location -g \
 *     --request GET \
 *     --url "$HMZ_URL_API/internal/v1/system/information"
 * ```
 *
 */

// The above comment must start at the immediate first line of the .tf file before any resource, variable, module, etc.
// See: https://terraform-docs.io/user-guide/configuration/header-from/ 

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
  pet_name = random_pet.random_name.id
}


resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}

module "vpc" {
  source = "./modules/vpc"
  count  = var.aws_enable_vpc_creation ? 1 : 0
}

data "aws_vpc" "aws_vpc_hmz_trusted_components" {
  id = var.aws_enable_vpc_creation ? module.vpc.0.vpc_id : var.aws_vpc_id
}

data "aws_subnet" "hmz_trusted_components_subnet" {
  id = var.aws_enable_vpc_creation ? module.vpc.0.private_subnet_id : var.aws_subnet_id
}

resource "aws_security_group" "ecs_https_egress" {
  count       = var.aws_security_group_id == "" ? 1 : 0
  name        = "ecs_https_egress_sg"
  description = "Security group for ECS container to allow outbound HTTPS traffic"
  vpc_id      = data.aws_vpc.aws_vpc_hmz_trusted_components.id

  egress {
    description = "Allow outbound HTTPS traffic on port 443"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # 0.0.0.0/0 represents all IP addresses
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ECS HTTPS Egress"
  }
}

data "aws_security_group" "hmz_trusted_components_sg" {
  id = var.aws_security_group_id == "" ? aws_security_group.ecs_https_egress.0.id : var.aws_security_group_id
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
  count = var.aws_ecs_cluster_name == "" ? 1 : 0
  name  = "${local.pet_name}-hmz-trusted-components-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_ecs_cluster" "aws_ecs_cluster_for_hmz_trusted_components" {
  cluster_name = var.aws_ecs_cluster_name == "" ? aws_ecs_cluster.cluster.0.name : var.aws_ecs_cluster_name
}

module "notary" {
  source = "./modules/notary"
  count  = var.hmz_notary_enabled ? 1 : 0

  random_pet = local.pet_name

  # AWS Config
  # aws_subnet_ids                 = [data.aws_subnet.hmz_trusted_components_subnet.id]
  aws_iam_role_ecs_task_role_arn     = aws_iam_role.ecs_task_role_for_hmz_trusted_components.arn
  aws_vpc_id                         = data.aws_vpc.aws_vpc_hmz_trusted_components.id
  aws_vpc_cidr                       = data.aws_vpc.aws_vpc_hmz_trusted_components.cidr_block
  aws_subnet_id                      = data.aws_subnet.hmz_trusted_components_subnet.id
  aws_cloud_watch_logs_group         = var.aws_cloud_watch_logs_group
  aws_cloud_watch_logs_stream_prefix = var.aws_cloud_watch_logs_stream_prefix
  aws_cloud_watch_logs_region        = var.aws_cloud_watch_logs_region
  aws_resource_tags                  = var.aws_resource_tags

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
  hmz_notary_open_telemetry_type          = var.hmz_notary_open_telemetry_type
  hmz_notary_otel_sdk_disabled            = var.hmz_notary_otel_sdk_disabled
  hmz_notary_hc_tracing_enabled           = var.hmz_notary_hc_tracing_enabled
  hmz_notary_log_level                    = var.hmz_notary_log_level
  hmz_notary_grpc_enabled                 = var.hmz_notary_grpc_enabled
  hmz_notary_cols_dir                     = var.hmz_notary_cols_dir
  hmz_notary_kms_grpc_keep_alive_interval = var.hmz_notary_kms_grpc_keep_alive_interval
  hmz_notary_kms_grpc_keep_alive_timeout  = var.hmz_notary_kms_grpc_keep_alive_timeout
  hmz_notary_state_manifest_file_path     = var.hmz_notary_state_manifest_file_path
  hmz_notary_state_manifest_signature     = var.hmz_notary_state_manifest_signature

  # Compulsory HMZ KMS Connect environment variables
  hmz_kms_connect_software_master_key = var.hmz_kms_connect_software_master_key
}

resource "aws_ecs_service" "hmz_notary_ecs_service" {

  desired_count   = 1
  name            = "hmz-notary-ecs-service"
  cluster         = data.aws_ecs_cluster.aws_ecs_cluster_for_hmz_trusted_components.id
  task_definition = module.notary.0.ecs_task_definition.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.hmz_trusted_components_subnet.id]
    security_groups = [data.aws_security_group.hmz_trusted_components_sg.id]
  }
}

module "vault" {
  source = "./modules/vault"

  for_each = {
    for index, vault in var.vaults :
    index => vault
  }

  random_pet = local.pet_name

  # AWS Config
  aws_iam_role_ecs_task_role_arn     = aws_iam_role.ecs_task_role_for_hmz_trusted_components.arn
  aws_vpc_id                         = data.aws_vpc.aws_vpc_hmz_trusted_components.id
  aws_vpc_cidr                       = data.aws_vpc.aws_vpc_hmz_trusted_components.cidr_block
  aws_subnet_id                      = data.aws_subnet.hmz_trusted_components_subnet.id
  aws_cloud_watch_logs_group         = var.aws_cloud_watch_logs_group
  aws_cloud_watch_logs_stream_prefix = var.aws_cloud_watch_logs_stream_prefix
  aws_cloud_watch_logs_region        = var.aws_cloud_watch_logs_region
  aws_resource_tags                  = var.aws_resource_tags

  hmz_kms_oci_image                   = var.hmz_kms_oci_image
  hmz_kms_oci_tag                     = var.hmz_kms_oci_tag
  hmz_kms_container_registry_user     = coalesce(var.hmz_kms_container_registry_user, var.hmz_metaco_container_registry_user)
  hmz_kms_container_registry_password = coalesce(var.hmz_kms_container_registry_password, var.hmz_metaco_container_registry_password)

  hmz_vault_oci_image                   = var.hmz_vault_oci_image
  hmz_vault_oci_tag                     = var.hmz_vault_oci_tag
  hmz_vault_container_registry_user     = coalesce(var.hmz_vault_container_registry_user, var.hmz_metaco_container_registry_user)
  hmz_vault_container_registry_password = coalesce(var.hmz_vault_container_registry_password, var.hmz_metaco_container_registry_password)

  // Same environment variables for all vaults
  hmz_vault_harmonize_core_endpoint             = var.hmz_vault_harmonize_core_endpoint
  hmz_vault_trusted_notary_messaging_public_key = var.hmz_vault_trusted_notary_messaging_public_key
  hmz_kms_connect_software_master_key           = var.hmz_kms_connect_software_master_key

  // Specific environment variables for each vault
  hmz_vault_id                     = each.value.hmz_vault_id
  hmz_vault_log_level              = each.value.hmz_vault_log_level
  hmz_vault_bridge_log_level       = each.value.hmz_vault_bridge_log_level
  hmz_vault_feature_otlp_in_stdout = each.value.hmz_vault_feature_otlp_in_stdout
  hmz_vault_optional_maximum_fee   = each.value.hmz_vault_optional_maximum_fee
}

resource "aws_ecs_service" "hmz_vault_ecs_service" {

  depends_on = [module.vault]

  for_each = {
    for index, vault in var.vaults :
    index => vault
  }

  desired_count   = 1
  name            = "hmz-vault-${each.value.hmz_vault_id}-ecs-service"
  cluster         = data.aws_ecs_cluster.aws_ecs_cluster_for_hmz_trusted_components.id
  task_definition = module.vault[each.key].ecs_task_definition.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.hmz_trusted_components_subnet.id]
    security_groups = [data.aws_security_group.hmz_trusted_components_sg.id]
  }
}
