locals {
  pet_name            = random_pet.random_name.id
  pet_name_underscore = replace(local.pet_name, "-", "_")

  hmz_vault_environment_variables = {
    # HMZ Vault Environment variables: Telemetry
    HMZ_FEATURE_OTLP_IN_STDOUT = var.hmz_vault_feature_otlp_in_stdout
    VAULT_LOGLEVEL             = var.hmz_vault_log_level
    VAULT_BRIDGE_LOGLEVEL      = var.hmz_vault_bridge_log_level

    # HMZ Vault Environment variables: Network
    HARMONIZE_CORE_ENDPOINT = "${var.hmz_vault_harmonize_core_endpoint}/internal/v1"

    # HMZ Vault Environment variables: Vault HMZ Config
    TRUSTED_SIG = "pem:${var.hmz_vault_trusted_sig}"
    VAULT_ID    = var.hmz_vault_id

    # HMZ Vault 
    VAULT_KMS_ENDPOINT = "localhost:10000"
    VAULT_CORE_ADDRESS = "localhost:10054"
  }

  hmz_kms_environment_variables = {
    KMS_SOFT_MASTER = var.hmz_kms_software_master_key
  }

  aws_ecs_task_container_registry_credentials = {
    username = var.hmz_kms_container_registry_user,
    password = var.hmz_kms_container_registry_password
  }

  # log_config = length(var.aws_cloud_watch_logs_group) > 0 && length(var.aws_cloud_watch_logs_region) > 0 ? {
  #   logDriver = "awslogs"
  #   options = {
  #     awslogs-group         = var.aws_cloud_watch_logs_group
  #     awslogs-region        = var.aws_cloud_watch_logs_region
  #     awslogs-stream-prefix = "ecs"
  #   }
  # } : null

  log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = var.aws_cloud_watch_logs_group
      awslogs-region        = var.aws_cloud_watch_logs_region
      awslogs-stream-prefix = "ecs"
    }
  }
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

resource "aws_secretsmanager_secret" "hmz_vault_oci_registry_credentials" {
  name = "${local.pet_name}-hmz-vault-oci-registry-credentials"
}

resource "aws_secretsmanager_secret_version" "hmz_vault_oci_registry_credentials" {
  secret_id = aws_secretsmanager_secret.hmz_vault_oci_registry_credentials.id
  secret_string = jsonencode({
    username = var.hmz_vault_container_registry_user,
    password = var.hmz_vault_container_registry_password
  })
}

resource "aws_secretsmanager_secret" "hmz_kms_oci_registry_credentials" {
  name = "${local.pet_name}-hmz-kms-for-vault-oci-registry-credentials"
}

resource "aws_secretsmanager_secret_version" "hmz_kms_oci_registry_credentials" {
  secret_id = aws_secretsmanager_secret.hmz_kms_oci_registry_credentials.id
  secret_string = jsonencode({
    username = var.hmz_kms_container_registry_user,
    password = var.hmz_kms_container_registry_password
  })
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
          aws_secretsmanager_secret.hmz_kms_oci_registry_credentials.arn,
          aws_secretsmanager_secret.hmz_vault_oci_registry_credentials.arn
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
        credentialsParameter = aws_secretsmanager_secret.hmz_vault_oci_registry_credentials.arn
      }
      environment = [
        for key, value in local.hmz_vault_environment_variables : {
          name  = key
          value = tostring(value)
        }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
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
        credentialsParameter = aws_secretsmanager_secret.hmz_kms_oci_registry_credentials.arn
      }
      entryPoint = ["/bin/sh", "-c"]
      command = [
        "mkdir -p /opt/kms/cfg && echo 'master = [${local.hmz_kms_environment_variables["KMS_SOFT_MASTER"]}]' > /opt/kms/cfg/soft.cfg && chmod 444 /opt/kms/cfg/soft.cfg && exec /usr/bin/kms"
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
