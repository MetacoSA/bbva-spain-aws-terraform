locals {
  pet_name            = random_pet.random_name.id
  pet_name_underscore = replace(local.pet_name, "-", "_")

  hmz_notary_environment_variables = merge({
    HMZ_OPEN_TELEMETRY_TYPE                 = var.hmz_notary_open_telemetry_type
    OTEL_SDK_DISABLED                       = var.hmz_notary_otel_sdk_disabled
    HMZ_HC_TRACING_ENABLED                  = var.hmz_notary_hc_tracing_enabled
    HMZ_LOG_LEVEL                           = var.hmz_notary_log_level
    HMZ_NOTARY_BRIDGE_GRPC_ENABLED          = var.hmz_notary_grpc_enabled
    HMZ_NOTARY_BRIDGE_HTTP_ENABLED          = var.hmz_notary_http_enabled
    HMZ_NOTARY_BRIDGE_HTTP_URI              = var.hmz_notary_bridge_http_endpoint
    HMZ_NOTARY_COLS_DIR                     = var.hmz_notary_cols_dir
    HMZ_NOTARY_KMS_GRPC_KEEP_ALIVE_INTERVAL = var.hmz_notary_kms_grpc_keep_alive_interval
    HMZ_NOTARY_KMS_GRPC_KEEP_ALIVE_TIMEOUT  = var.hmz_notary_kms_grpc_keep_alive_timeout
    HMZ_NOTARY_KMS_HOST                     = "localhost"
    HMZ_NOTARY_KMS_PORT                     = 10000
    },

    fileexists(var.hmz_notary_state_manifest_file_path) ? { ANTI_REWIND_RECOVERY_STATE_MANIFEST = file(var.hmz_notary_state_manifest_file_path) } : {},
    fileexists(var.hmz_notary_state_manifest_signature_file_path) ? { ANTI_REWIND_RECOVERY_STATE_MANIFEST_SIGNATURE = file(var.hmz_notary_state_manifest_signature_file_path) } : {}
  )

  hmz_kms_environment_variables = {
    KMS_SOFT_MASTER = var.hmz_kms_software_master_key
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

resource "aws_secretsmanager_secret" "hmz_notary_oci_registry_credentials" {
  name = "${local.pet_name}-hmz-notary-oci-registry-credentials"
}

resource "aws_secretsmanager_secret_version" "hmz_notary_oci_registry_credentials" {
  secret_id = aws_secretsmanager_secret.hmz_notary_oci_registry_credentials.id
  secret_string = jsonencode({
    username = var.hmz_notary_container_registry_user,
    password = var.hmz_notary_container_registry_password
  })
}

resource "aws_secretsmanager_secret" "hmz_kms_oci_registry_credentials" {
  name = "${local.pet_name}-hmz-kms-for-notary-oci-registry-credentials"
}

resource "aws_secretsmanager_secret_version" "hmz_kms_oci_registry_credentials" {
  secret_id = aws_secretsmanager_secret.hmz_kms_oci_registry_credentials.id
  secret_string = jsonencode({
    username = var.hmz_kms_container_registry_user,
    password = var.hmz_kms_container_registry_password
  })
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${local.pet_name}-ecs-execution-role-for-hmz-notary"

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
  name        = "${local.pet_name}-ecs-secrets-policy-for-notary"
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
          aws_secretsmanager_secret.hmz_notary_oci_registry_credentials.arn
        ]
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_policy.arn
}

resource "aws_security_group" "efs_sg" {
  vpc_id = var.aws_vpc_id

  # Assuming NFS traffic is allowed on port 2049
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr] # Update with your VPC CIDR
  }
}

resource "aws_efs_file_system" "hmz_notary_anti_rewind_file_efs" {
  creation_token = "${local.pet_name}-hmz-notary-anti-rewind-file-efs"

  tags = {
    Name = "${local.pet_name}-hmz-notary-anti-rewind-file-efs"
  }
}

resource "aws_efs_file_system" "hmz_notary_tmp_folder_efs" {
  creation_token = "${local.pet_name}-hmz-notary-tmp-folder-efs"

  tags = {
    Name = "${local.pet_name}-hmz-notary-tmp-folder-efs"
  }
}

resource "aws_efs_mount_target" "hmz_notary_anti_rewind_file_efs_mt" {
  # for_each       = toset(var.aws_subnet_ids)
  file_system_id = aws_efs_file_system.hmz_notary_tmp_folder_efs.id
  subnet_id      = data.aws_subnet.hmz_trusted_components_subnet.id

  # Use the security group that allows NFS traffic
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${local.pet_name}-hmz-notary-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  memory                   = "8192"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = var.aws_iam_role_ecs_task_role_arn

  # volume {
  #   name = "${local.pet_name}-hmz-notary-anti-rewind-file-volume"

  #   efs_volume_configuration {
  #     file_system_id     = aws_efs_file_system.hmz_notary_anti_rewind_file_efs.id
  #     root_directory     = "/"
  #     transit_encryption = "ENABLED"
  #   }
  # }

  # volume {
  #   name = "${local.pet_name}-hmz-notary-tmp-folder-volume"

  #   efs_volume_configuration {
  #     file_system_id     = aws_efs_file_system.hmz_notary_tmp_folder_efs.id
  #     root_directory     = "/"
  #     transit_encryption = "ENABLED"
  #   }
  # }

  container_definitions = jsonencode([
    {
      name      = "${local.pet_name}-hmz-notary-container"
      image     = "${var.hmz_notary_oci_image}:${var.hmz_notary_oci_tag}"
      cpu       = 2048
      memory    = 4096
      essential = true
      repositoryCredentials = {
        credentialsParameter = aws_secretsmanager_secret.hmz_notary_oci_registry_credentials.arn
      }
      environment = [
        for key, value in local.hmz_notary_environment_variables : {
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
      # mountPoints = [
      #   {
      #     sourceVolume  = "${local.pet_name}-hmz-notary-anti-rewind-file-volume"
      #     containerPath = "/data/anti-rewind"
      #     readOnly      = false
      #   },
      #   {
      #     sourceVolume  = "${local.pet_name}-hmz-notary-tmp-folder-volume"
      #     containerPath = "/tmp"
      #     readOnly      = false
      #   }
      # ]
      logConfiguration = local.log_config
    },
    {
      name      = "${local.pet_name}-hmz-kms-connect-for-notary"
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
