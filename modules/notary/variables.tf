
variable "random_pet" {
  description = "Random Pet"
  type        = string
  default     = ""
}

# AWS config

variable "aws_vpc_id" {
  description = "AWS VPC ID"
  type        = string
  validation {
    condition     = can(regex("^vpc-[a-fA-F0-9]{17}$", var.aws_vpc_id))
    error_message = "The AWS VPC ID must be in the format 'vpc-xxxxxxxxxxxxxxxxx'."
  }
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR block"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.aws_vpc_cidr))
    error_message = "The VPC CIDR block is not in the correct format. Expected format is x.x.x.x/y."
  }
}

variable "aws_subnet_id" {
  description = "AWS Subnet ID"
  type        = string
  validation {
    condition     = can(regex("^subnet-[a-fA-F0-9]{17}$", var.aws_subnet_id))
    error_message = "The AWS subnet ID must be in the format 'subnet-xxxxxxxxxxxxxxxxx'."
  }
}

variable "aws_security_group_id" {
  description = "AWS Security Group ID"
  type        = string
  validation {
    condition     = can(regex("^$|^sg-[0-9a-fA-F]{8,17}$", var.aws_security_group_id))
    error_message = "The Security Group ID must be empty or in the format 'sg-xxxxxxxx'."
  }
}

variable "aws_ecs_cluster_name" {
  description = "AWS ECS Cluster Name"
  type        = string
}

variable "aws_iam_role_ecs_task_role_arn" {
  description = "AWS IAM Role ARN for ECS Task"
  type        = string

  validation {
    condition = (
      can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.aws_iam_role_ecs_task_role_arn))
    )
    error_message = "The provided AWS IAM Role ARN for ECS Task does not match any of the accepted formats"
  }
}

variable "aws_cloud_watch_logs_region" {
  description = "AWS CloudWatch Logs Region"
  type        = string
  default     = ""
  validation {
    condition = var.aws_cloud_watch_logs_region == "" || contains([
      "af-south-1",
      "ap-east-1",
      "ap-northeast-1",
      "ap-northeast-2",
      "ap-northeast-3",
      "ap-southeast-1",
      "ap-southeast-2",
      "ap-southeast-3",
      "ap-southeast-4",
      "ap-south-1",
      "ap-south-2",
      "ca-central-1",
      "eu-central-1",
      "eu-central-2",
      "eu-north-1",
      "eu-south-1",
      "eu-south-2",
      "eu-west-1",
      "eu-west-2",
      "eu-west-3",
      "il-central-1",
      "me-central-1",
      "me-south-1",
      "sa-east-1",
      "us-east-1",
      "us-east-2",
      "us-west-1",
      "us-west-2",
    ], var.aws_cloud_watch_logs_region)

    error_message = "The specified region (${var.aws_cloud_watch_logs_region}) is not valid. Please choose a valid AWS region."
  }
}

variable "aws_cloud_watch_logs_group" {
  description = "AWS CloudWatch Logs Group"
  type        = string
  default     = ""
}

variable "aws_cloud_watch_logs_stream_prefix" {
  description = "AWS CloudWatch Logs Stream Prefix"
  type        = string
  default     = ""
  # default     = "hmz-trusted-components"
}

variable "aws_resource_tags" {
  type        = map(string)
  default     = {}
  description = "A map of labels to be applied to the resource."

  validation {
    condition     = !contains(keys(var.aws_resource_tags), "Name") && !contains(keys(var.aws_resource_tags), "name")
    error_message = "The labels map must not contain keys named 'Name' or 'name'."
  }
}

variable "aws_secrets_manager_arn_for_hmz_notary_oci_registry_credentials" {
  description = "AWS Secrets Manager Secret ARN for HMZ Notary OCI registry credentials"
  type        = string
  default     = ""
}

variable "aws_secrets_manager_arn_for_hmz_kms_connect_oci_registry_credentials" {
  description = "AWS Secrets Manager Secret ARN for HMZ KMS Connect OCI registry credentials"
  type        = string
  default     = ""
}

## HMZ KMS Container

variable "hmz_kms_oci_image" {
  type        = string
  default     = "metaco.azurecr.io/harmonize/kms-soft"
  description = "KMS Connect OCI Image"

  validation {
    condition     = length(var.hmz_kms_oci_image) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_kms_oci_tag" {
  type        = string
  description = "KMS Connect OCI Tag"

  validation {
    condition     = length(var.hmz_kms_oci_tag) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_kms_container_registry_user" {
  type        = string
  sensitive   = true
  description = "KMS Container Registry User"

  validation {
    condition     = length(var.hmz_kms_container_registry_user) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_kms_container_registry_password" {
  type        = string
  sensitive   = true
  description = "KMS Container Registry Password"

  validation {
    condition     = length(var.hmz_kms_container_registry_password) > 0
    error_message = "Must non empty string"
  }
}

## HMZ Notary Container

variable "hmz_notary_oci_image" {
  type        = string
  default     = "metaco.azurecr.io/harmonize/approval-notary"
  description = "HMZ Notary OCI Image"

  validation {
    condition     = length(var.hmz_notary_oci_image) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_notary_oci_tag" {
  type        = string
  description = "HMZ Notary OCI Tag"

  validation {
    condition     = length(var.hmz_notary_oci_tag) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_notary_container_registry_user" {
  type        = string
  sensitive   = true
  description = "HMZ Notary Container Registry User"

  validation {
    condition     = length(var.hmz_notary_container_registry_user) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_notary_container_registry_password" {
  type        = string
  sensitive   = true
  description = "HMZ Notary Container Registry Password"

  validation {
    condition     = length(var.hmz_notary_container_registry_password) > 0
    error_message = "Must non empty string"
  }
}

# HMZ KMS Environment Variables

variable "hmz_kms_connect_software_master_key" {
  type        = string
  sensitive   = true
  description = "Software KMS Master Key. (Environment Variable HMZ_KMS_CONNECT_SOFTWARE_MASTER_KEY, e.g. HMZ_KMS_CONNECT_SOFTWARE_MASTER_KEY='79acc37afb7b2e0da4afb3a350ce49b73a24555431b0211dbf0bf93886c0fbff')"

  validation {
    condition     = var.hmz_kms_connect_software_master_key == "" || can(regex("^[0-9a-fA-F]+$", var.hmz_kms_connect_software_master_key))
    error_message = "The Software KMS Master Key value must be a hexadecimal string."
  }
}

# Notary Environment Variables

variable "hmz_notary_open_telemetry_type" {
  type        = string
  default     = "disabled"
  description = "HMZ Notary type of Telemetry (Environment Variable HMZ_OPEN_TELEMETRY_TYPE)"

  validation {
    error_message = "Value must be one of the available Open Telemetry Type: enable, otlp"
    condition = contains([
      "disabled",
      "otlp",
    ], var.hmz_notary_open_telemetry_type)
  }
}

variable "hmz_notary_otel_sdk_disabled" {
  type        = bool
  default     = true
  description = "HMZ Notary enables or disables Open Telemetry SDK (Environment Variable OTEL_SDK_DISABLED)"
}

variable "hmz_notary_hc_tracing_enabled" {
  type        = bool
  default     = false
  description = "HMZ Notary enables or disables Health Check Tracing (Environment Variable HMZ_HC_TRACING_ENABLED)"
}

// ERROR: This log entry notes that at least one system component is inoperable and is interfering with the operability of other functionalities.
// WARN: This log message indicates that an unexpected event has occurred in an application that may disrupt or delay other processes.
// INFO: This log level captures an event that has occurred, though it does not appear to affect operations. These alerts usually can be ignored, assuming the rest of the system continues to operate normally.
// DEBUG: The debug log captures relevant detail of events that may be useful during software debugging or troubleshooting within the test environment.
// TRACE: This log level captures the execution of code. It is considered an info message and does not require action. That said, it may prove useful when the team needs full visibility within the application or a third-party library.
variable "hmz_notary_log_level" {
  type        = string
  default     = "INFO"
  description = "Logging level"

  validation {
    error_message = "Value must be one of the available logging Level: ERROR, WARN, INFO, DEBUG, TRACE."
    condition = contains([
      "ERROR",
      "WARN",
      "INFO",
      "DEBUG",
      "TRACE",
    ], var.hmz_notary_log_level)
  }
}

variable "hmz_notary_grpc_enabled" {
  type        = bool
  default     = false
  description = "Enables grpc communication with the notary bridge"
}

variable "hmz_notary_http_enabled" {
  type        = bool
  default     = true
  description = "Enables http communication with the notary bridge"
}

variable "hmz_notary_bridge_http_endpoint" {
  type        = string
  description = "Harmonize notary bridge API endpoint"

  validation {
    error_message = "Value must be an HTTP(s) URL without a trailing slash."
    condition = alltrue([
      can(regex("^http", var.hmz_notary_bridge_http_endpoint)),
      !can(regex("/$", var.hmz_notary_bridge_http_endpoint)),
    ])
  }
}

variable "hmz_notary_cols_dir" {
  type        = string
  default     = "/data/anti-rewind"
  description = "HMZ Notary storage folder of the Anti-Rewind File (Environment Variable HMZ_NOTARY_COLS_DIR)"
}

variable "hmz_notary_kms_grpc_keep_alive_interval" {
  type        = number
  default     = 10
  description = "HMZ Notary gRPC connection to KMS Connect: Keep alive interval in seconds"
}

variable "hmz_notary_kms_grpc_keep_alive_timeout" {
  type        = number
  default     = 10
  description = "HMZ Notary gRPC connection to KMS Connect: Keep alive timeout in seconds"
}

variable "hmz_notary_state_manifest_file_path" {
  type        = string
  default     = "manifest.json"
  description = "Path to manifest.json file that contains the Anti-Rewind state manifest"
}

variable "hmz_notary_state_manifest_signature" {
  type        = string
  default     = ""
  description = "HMZ Notary Anti-Rewind state manifest signature (Disaster Recovery Procedure)"
}

