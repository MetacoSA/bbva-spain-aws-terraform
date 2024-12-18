# AWS Setup

variable "aws_enable_vpc_creation" {
  type        = bool
  default     = false
  description = "Set this flag to true to enable AWS VPC Creation"
}

variable "aws_region" {
  description = "The AWS region where Cloud resources will be deployed"
  type        = string

  validation {
    condition = contains([
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
    ], var.aws_region)

    error_message = "The specified region (${var.aws_region}) is not valid. Please choose a valid AWS region."
  }
}

variable "aws_vpc_id" {
  description = "AWS VPC ID for Security Group HMZ Notary Anti-Rewind file"
  type        = string
  default     = ""
  validation {
    condition     = var.aws_vpc_id == "" || can(regex("^$|^vpc-[0-9a-fA-F]{8,17}$", var.aws_vpc_id))
    error_message = "The VPC ID must be empty or in the format 'vpc-xxxxxxxx'."
  }
}

variable "aws_subnet_id" {
  description = "AWS Subnet ID"
  type        = string
  default     = ""
  validation {
    condition     = var.aws_subnet_id == "" || can(regex("^subnet-[a-fA-F0-9]{17}$", var.aws_subnet_id))
    error_message = "The AWS subnet ID must be in the format 'subnet-xxxxxxxxxxxxxxxxx'."
  }
}

variable "aws_security_group_id" {
  description = "AWS Security Group ID"
  type        = string
  default     = ""
  validation {
    condition     = var.aws_security_group_id == "" || can(regex("^$|^sg-[0-9a-fA-F]{8,17}$", var.aws_security_group_id))
    error_message = "The Security Group ID must be empty or in the format 'sg-xxxxxxxx'."
  }
}

variable "aws_ecs_cluster_name" {
  description = "AWS ECS Cluster Name"
  type        = string
  default     = ""
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
}

variable "aws_resource_tags" {
  description = "A map of labels to be applied to the resource ('Name' or 'name' keys excluded)."
  type        = map(string)
  default     = {}

  validation {
    condition     = !contains(keys(var.aws_resource_tags), "Name") && !contains(keys(var.aws_resource_tags), "name")
    error_message = "The labels map must not contain keys named 'Name' or 'name'."
  }
}

variable "aws_secrets_manager_arn_for_hmz_oci_registry_credentials" {
  description = "AWS Secrets Manager Secret ARN for Harmonize OCI registry credentials"
  type        = string
  default     = ""
}

# HMZ
variable "hmz_notary_enabled" {
  type        = bool
  default     = false
  description = "Set this flag to true to enable Notary instance deployment."
}

variable "hmz_kms_connect_software_master_key" {
  type        = string
  sensitive   = true
  default     = ""
  description = "HMZ KMS Connect Software Master Key (hexadecimal). (Environment Variable HMZ_KMS_CONNECT_SOFTWARE_MASTER_KEY, e.g. HMZ_KMS_CONNECT_SOFTWARE_MASTER_KEY='79acc37afb7b2e0da4afb3a350ce49b73a24555431b0211dbf0bf93886c0fbff')"

  validation {
    condition     = var.hmz_kms_connect_software_master_key == "" || can(regex("^[0-9a-fA-F]+$", var.hmz_kms_connect_software_master_key))
    error_message = "The kms_soft_master value must be a hexadecimal string."
  }
}

## Container Registries Credentials

variable "hmz_metaco_container_registry_user" {
  type        = string
  sensitive   = true
  description = "Metaco Container Registry User"

  validation {
    condition     = length(var.hmz_metaco_container_registry_user) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_metaco_container_registry_password" {
  type        = string
  sensitive   = true
  description = "Metaco Container Registry Password"

  validation {
    condition     = length(var.hmz_metaco_container_registry_password) > 0
    error_message = "Must non empty string"
  }
}

## HMZ KMS Container

variable "hmz_kms_oci_image" {
  type        = string
  default     = "metaco.azurecr.io/harmonize/kms-soft"
  description = "HMZ KMS Connect OCI Image"

  validation {
    condition     = length(var.hmz_kms_oci_image) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_kms_oci_tag" {
  type        = string
  description = "HMZ KMS Connect OCI Tag"

  validation {
    condition     = length(var.hmz_kms_oci_tag) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_kms_container_registry_user" {
  type        = string
  default     = null
  sensitive   = true
  description = "HMZ KMS Connect Container Registry User"
}

variable "hmz_kms_container_registry_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "HMZ KMS Connect Container Registry Password"
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
  default     = null
  sensitive   = true
  description = "HMZ Notary Container Registry User"
}

variable "hmz_notary_container_registry_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "HMZ Notary Container Registry Password"
}

## HMZ Vault Container

variable "hmz_vault_oci_image" {
  type        = string
  default     = "metaco.azurecr.io/harmonize/vault-releases"
  description = "HMZ Vault OCI Image"

  validation {
    condition     = length(var.hmz_vault_oci_image) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_oci_tag" {
  type        = string
  description = "HMZ Vault OCI Tag"

  validation {
    condition     = length(var.hmz_vault_oci_tag) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_container_registry_user" {
  type        = string
  default     = null
  sensitive   = true
  description = "HMZ Vault Container Registry User"
}

variable "hmz_vault_container_registry_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "HMZ Vault Container Registry Password"
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
  description = "HMZ Notary Logging level"

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
  description = "Enables grpc communication with the Notary Bridge"
}

variable "hmz_notary_http_enabled" {
  type        = bool
  default     = true
  description = "Enables http communication with the Notary Bridge"
}

variable "hmz_notary_bridge_http_endpoint" {
  type        = string
  description = "Harmonize Notary bridge API endpoint"

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


# Vaults Environment Variables

variable "vaults" {

  type = list(object({
    hmz_vault_id                     = string
    hmz_vault_log_level              = number
    hmz_vault_bridge_log_level       = number
    hmz_vault_feature_otlp_in_stdout = bool
    hmz_vault_optional_maximum_fee   = bool
  }))

  default     = []
  description = "List of Ripple Custody Vault instances."

  validation {
    condition     = length(var.vaults) == length(distinct([for vault in var.vaults : vault.hmz_vault_id]))
    error_message = "Each hmz_vault_id must be unique."
  }

  validation {
    condition     = alltrue([for vault in var.vaults : can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", vault.hmz_vault_id))])
    error_message = "Value must be and UUID (36 hex or - characters)."
  }

  validation {
    condition     = alltrue([for vault in var.vaults : contains([3, 4, 6, 7], vault.hmz_vault_log_level)])
    error_message = "The hmz_vault_log_level must be one of the specified integers (3=error, 4=warning, 6=info, 7=debug)."
  }

  validation {
    condition     = alltrue([for vault in var.vaults : contains([3, 4, 6, 7], vault.hmz_vault_bridge_log_level)])
    error_message = "The hmz_vault_bridge_log_level must be one of the specified integers (3=error, 4=warning, 6=info, 7=debug)."
  }
}

variable "hmz_vault_harmonize_core_endpoint" {
  type        = string
  description = "HMZ Vault Environment Variable HARMONIZE_CORE_ENDPOINT (Vault Core Endpoint)"

  validation {
    error_message = "Value must be an HTTP(s) URL without a trailing slash and without '/internal/v1'."
    condition = alltrue([
      can(regex("^(http|https)://[a-zA-Z0-9.-]+$", var.hmz_vault_harmonize_core_endpoint)),
      !can(regex("internal/v1", var.hmz_vault_harmonize_core_endpoint))
    ])
  }
}


variable "hmz_vault_trusted_notary_messaging_public_key" {
  type        = string
  default     = ""
  description = "System (Notary) public key, which is listed as part of the first system event confirming the genesis execution (Environment Variable VAULT_TRUSTED_SIG, without the 'pem:' at the beginning)."

  validation {
    error_message = "Value must be empty or it must be a base64 encoded public key. Omit the the 'pem:' prefix"
    condition = anytrue([
      length(var.hmz_vault_trusted_notary_messaging_public_key) == 0,
      !can(regex("^pem:", var.hmz_vault_trusted_notary_messaging_public_key)),
    ])
  }
}

variable "hmz_vault_harmonize_core_proxy_address" {
  type        = string
  description = "HMZ Vault Environment Variable HARMONIZE_CORE_PROXY_ADDRESS"
  default     = ""

  validation {
    condition     = var.hmz_vault_harmonize_core_proxy_address == "" || can(regex("^(http|https)://((?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,6}\\.?)|([0-9]{1,3}\\.){3}[0-9]{1,3})", var.hmz_vault_harmonize_core_proxy_address))
    error_message = "The hmz_vault_http_proxy must be a valid hostname. http:// or https:// prefix is required."
  }
}

variable "hmz_vault_harmonize_core_no_proxy_address" {
  type        = string
  description = "HMZ Vault Environment Variable HARMONIZE_CORE_NO_PROXY_ADDRESS"
  default     = ""

  validation {
    condition     = var.hmz_vault_harmonize_core_no_proxy_address == "" || can(regex("^(http|https)://((?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,6}\\.?)|([0-9]{1,3}\\.){3}[0-9]{1,3})", var.hmz_vault_harmonize_core_no_proxy_address))
    error_message = "The hmz_vault_no_proxy must be a valid hostname. http:// or https:// prefix is required."
  }
}
