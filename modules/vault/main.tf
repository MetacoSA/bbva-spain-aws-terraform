/**
 * # About
 *
 * Module for the Vault
 * 
 */

locals {
  pet_name            = var.random_pet != "" ? var.random_pet : random_pet.random_name.id
  pet_name_underscore = replace(local.pet_name, "-", "_")

  hmz_vault_environment_variables = {
    # HMZ Vault Environment variables: Telemetry
    HMZ_FEATURE_OTLP_IN_STDOUT = var.hmz_vault_feature_otlp_in_stdout
    VAULT_LOGLEVEL             = var.hmz_vault_log_level
    VAULT_BRIDGE_LOGLEVEL      = var.hmz_vault_bridge_log_level

    # HMZ Vault Environment variables: Network
    HARMONIZE_CORE_ENDPOINT = "${var.hmz_vault_harmonize_core_endpoint}/internal/v1"

    # HMZ Vault Environment variables: Vault HMZ Config
    HMZ_VAULT_TRUSTED_NOTARY_MESSAGING_PUBLIC_KEY = var.hmz_vault_trusted_notary_messaging_public_key != "" ? "pem:${var.hmz_vault_trusted_notary_messaging_public_key}" : ""
    VAULT_ID                                      = var.hmz_vault_id
    HMZ_OPTIONAL_MAXIMUM_FEE                      = var.hmz_vault_optional_maximum_fee

    # HMZ Vault 
    PLATFORM           = "kms"
    VAULT_KMS_ENDPOINT = "localhost:10000"
    VAULT_CORE_ADDRESS = "localhost:10054"
  }

  hmz_kms_environment_variables = {
    HMZ_KMS_CONNECT_SOFTWARE_MASTER_KEY = var.hmz_kms_connect_software_master_key
  }

  aws_ecs_task_container_registry_credentials = {
    username = var.hmz_kms_container_registry_user,
    password = var.hmz_kms_container_registry_password
  }

  log_config = length(var.aws_cloud_watch_logs_group) > 0 && length(var.aws_cloud_watch_logs_region) > 0 && length(var.aws_cloud_watch_logs_stream_prefix) > 0 ? {
    logDriver = "awslogs"
    options = {
      awslogs-group         = var.aws_cloud_watch_logs_group
      awslogs-region        = var.aws_cloud_watch_logs_region
      awslogs-stream-prefix = var.aws_cloud_watch_logs_stream_prefix
    }
  } : null
}

resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}

data "aws_vpc" "aws_vpc_hmz_trusted_components" {
  id = var.aws_vpc_id
}

data "aws_subnet" "hmz_trusted_components_subnet" {
  id = var.aws_subnet_id
}

data "aws_ecs_cluster" "aws_ecs_cluster_for_hmz_trusted_components" {
  cluster_name = var.aws_ecs_cluster_name
}

data "aws_security_group" "hmz_trusted_components_sg" {
  id = var.aws_security_group_id
}

# AWS Secrets Manager

# resource "aws_secretsmanager_secret" "hmz_vault_oci_registry_credentials" {
#   count = var.aws_secrets_manager_arn_for_hmz_vault_oci_registry_credentials == "" ? 1 : 0
#   name  = "${local.pet_name}-hmz-vault-oci-registry-credentials"
# }

# resource "aws_secretsmanager_secret_version" "hmz_vault_oci_registry_credentials" {
#   count     = var.aws_secrets_manager_arn_for_hmz_vault_oci_registry_credentials == "" ? 1 : 0
#   secret_id = aws_secretsmanager_secret.hmz_vault_oci_registry_credentials.0.id
#   secret_string = jsonencode({
#     username = var.hmz_vault_container_registry_user,
#     password = var.hmz_vault_container_registry_password
#   })
# }

data "aws_secretsmanager_secret" "hmz_vault_oci_registry_credentials" {
  # arn = var.aws_secrets_manager_arn_for_hmz_vault_oci_registry_credentials == "" ? aws_secretsmanager_secret.hmz_vault_oci_registry_credentials.0.arn : var.aws_secrets_manager_arn_for_hmz_vault_oci_registry_credentials
  arn = var.aws_secrets_manager_arn_for_hmz_vault_oci_registry_credentials
}

# resource "aws_secretsmanager_secret" "hmz_kms_connect_oci_registry_credentials" {
#   count = var.aws_secrets_manager_arn_for_hmz_kms_connect_oci_registry_credentials == "" ? 1 : 0
#   name  = "${local.pet_name}-hmz-kms-connect-for-vault-oci-registry-credentials"
# }

# resource "aws_secretsmanager_secret_version" "hmz_kms_connect_oci_registry_credentials" {
#   count     = var.aws_secrets_manager_arn_for_hmz_kms_connect_oci_registry_credentials == "" ? 1 : 0
#   secret_id = aws_secretsmanager_secret.hmz_kms_connect_oci_registry_credentials.0.id
#   secret_string = jsonencode({
#     username = var.hmz_kms_container_registry_user,
#     password = var.hmz_kms_container_registry_password
#   })
# }

data "aws_secretsmanager_secret" "hmz_kms_connect_oci_registry_credentials" {
  # arn = var.aws_secrets_manager_arn_for_hmz_kms_connect_oci_registry_credentials == "" ? aws_secretsmanager_secret.hmz_kms_connect_oci_registry_credentials.0.arn : var.aws_secrets_manager_arn_for_hmz_kms_connect_oci_registry_credentials
  arn = var.aws_secrets_manager_arn_for_hmz_kms_connect_oci_registry_credentials
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${local.pet_name}-ecs-execution-role-for-hmz-vault"

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

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_secrets_policy" {
  name        = "${local.pet_name}-ecs-secrets-policy-for-vault"
  description = "ECS policy to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Effect = "Allow",
        Resource = [
          data.aws_secretsmanager_secret.hmz_vault_oci_registry_credentials.arn,
          data.aws_secretsmanager_secret.hmz_kms_connect_oci_registry_credentials.arn
        ]

      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_policy.arn
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${local.pet_name}-hmz-vault-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  memory                   = "8192"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = var.aws_iam_role_ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${local.pet_name}-hmz-vault-${var.hmz_vault_id}"
      image     = "${var.hmz_vault_oci_image}:${var.hmz_vault_oci_tag}"
      cpu       = 2048
      memory    = 4096
      essential = true
      repositoryCredentials = {
        credentialsParameter = data.aws_secretsmanager_secret.hmz_vault_oci_registry_credentials.arn
      }
      # user       = "root"
      user       = "1001"
      entryPoint = ["/bin/sh", "-c"]
      command = [
        "mkdir -p /opt/vault-core/cfg/ && echo 'trusted.sig += [HMZ_VAULT_TRUSTED_NOTARY_MESSAGING_PUBLIC_KEY]' > /opt/vault-core/cfg/vault.cfg && chmod 444 /opt/vault-core/cfg/vault.cfg && exec /opt/entrypoint.sh 2>&1 | /opt/also_to_syslog.sh"
      ]
      environment = [
        for key, value in local.hmz_vault_environment_variables : {
          name  = key
          value = tostring(value)
        }
      ]
      logConfiguration = local.log_config
    },
    {
      name      = "${local.pet_name}-hmz-kms-connect-for-vault-${var.hmz_vault_id}"
      image     = "${var.hmz_kms_oci_image}:${var.hmz_kms_oci_tag}"
      cpu       = 2048
      memory    = 4096
      essential = true
      repositoryCredentials = {
        credentialsParameter = data.aws_secretsmanager_secret.hmz_kms_connect_oci_registry_credentials.arn
      }
      user = "root"
      # user       = "1001"
      entryPoint = ["/bin/sh", "-c"]
      command = [
        "mkdir -p /opt/kms/cfg && echo 'master = [HMZ_KMS_CONNECT_SOFTWARE_MASTER_KEY]' > /opt/kms/cfg/soft.cfg && chmod 444 /opt/kms/cfg/soft.cfg && exec /usr/bin/kms"
      ]
      environment = [
        for key, value in local.hmz_kms_environment_variables : {
          name  = key
          value = tostring(value)
        }
      ]
      portMappings = [
        {
          containerPort = 10000
          hostPort      = 10000
        }
      ]
      logConfiguration = local.log_config
    }
  ])
}

resource "aws_ecs_service" "service" {

  desired_count   = 1
  name            = "${local.pet_name}-hmz-vault-${var.hmz_vault_id}-ecs-service"
  cluster         = data.aws_ecs_cluster.aws_ecs_cluster_for_hmz_trusted_components.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.hmz_trusted_components_subnet.id]
    security_groups = [data.aws_security_group.hmz_trusted_components_sg.id]
  }
}
