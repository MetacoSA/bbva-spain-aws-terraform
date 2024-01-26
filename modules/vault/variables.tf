variable "random_pet" {
  description = "Random Pet"
  type        = string
  default     = ""
}

# AWS config

variable "aws_vpc_id" {
  description = "AWS VPC ID for Security Group HMZ Vault Anti-Rewind file"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR block for Security Group HMZ Vault Anti-Rewind file"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.aws_vpc_cidr))
    error_message = "The VPC CIDR block is not in the correct format. Expected format is x.x.x.x/y."
  }
}

variable "aws_subnet_id" {
  description = "AWS Subnet ID"
  type        = string
}

# variable "aws_subnet_ids" {
#   description = "AWS subnet ID for EFS HMZ Vault Anti-Rewind file"
#   type        = string
# }

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
  type        = map(string)
  default     = {}
  description = "A map of labels to be applied to the resource."

  validation {
    condition     = !contains(keys(var.aws_resource_tags), "Name") && !contains(keys(var.aws_resource_tags), "name")
    error_message = "The labels map must not contain keys named 'Name' or 'name'."
  }
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

## HMZ Vault Container

variable "hmz_vault_oci_image" {
  type        = string
  default     = "metaco.azurecr.io/harmonize/vault-releases"
  description = "Vault Connect OCI Image"

  validation {
    condition     = length(var.hmz_vault_oci_image) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_oci_tag" {
  type        = string
  description = "Vault Connect OCI Tag"

  validation {
    condition     = length(var.hmz_vault_oci_tag) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_container_registry_user" {
  type        = string
  sensitive   = true
  description = "Vault Container Registry User"

  validation {
    condition     = length(var.hmz_vault_container_registry_user) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_container_registry_password" {
  type        = string
  sensitive   = true
  description = "Vault Container Registry Password"

  validation {
    condition     = length(var.hmz_vault_container_registry_password) > 0
    error_message = "Must non empty string"
  }
}

# HMZ KMS Environment Variables

variable "hmz_kms_software_master_key" {
  type        = string
  sensitive   = true
  description = "Software KMS Master Key. (Environment Variable KMS_SOFT_MASTER, e.g. KMS_SOFT_MASTER='79acc37afb7b2e0da4afb3a350ce49b73a24555431b0211dbf0bf93886c0fbff')"

  validation {
    condition     = var.hmz_kms_software_master_key == "" || can(regex("^[0-9a-fA-F]+$", var.hmz_kms_software_master_key))
    error_message = "The Software KMS Master Key value must be a hexadecimal string."
  }
}


# HMZ Vault Environment Variables

variable "hmz_vault_feature_otlp_in_stdout" {
  type        = bool
  default     = false
  description = "Vault Environment Variable HMZ_FEATURE_OTLP_IN_STDOUT (Display logs in JSON format)"
}

variable "hmz_vault_log_level" {
  type        = number
  default     = 6
  description = "Vault Environment Variable VAULT_LOGLEVEL"

  validation {
    condition     = contains([3, 4, 6, 7], var.hmz_vault_log_level)
    error_message = "The hmz_vault_log_level must be one of the specified integers (3=error, 4=warning, 6=info, 7=debug)."
  }
}

variable "hmz_vault_bridge_log_level" {
  type        = number
  default     = 6
  description = "Vault Environment Variable VAULT_BRIDGE_LOGLEVEL"

  validation {
    condition     = contains([3, 4, 6, 7], var.hmz_vault_bridge_log_level)
    error_message = "The hmz_vault_bridge_log_level must be one of the specified integers (3=error, 4=warning, 6=info, 7=debug)."
  }
}

variable "hmz_vault_harmonize_core_endpoint" {
  type        = string
  description = "Vault Environment Variable HARMONIZE_CORE_ENDPOINT (Vault Core Endpoint)"

  validation {
    error_message = "Value must be an HTTP(s) URL without a trailing slash and without '/internal/v1'."
    condition = alltrue([
      can(regex("^(http|https)://[a-zA-Z0-9.-]+$", var.hmz_vault_harmonize_core_endpoint)),
      !can(regex("internal/v1", var.hmz_vault_harmonize_core_endpoint))
    ])
  }
}


variable "hmz_vault_trusted_sig" {
  type        = string
  default     = ""
  description = "System (Vault) public key, which is listed as part of the first system event confirming the genesis execution (Environment Variable TRUSTED_SIG, without the 'pem:' at the beginning)."

  validation {
    error_message = "Value must be empty or it must be a base64 encoded public key. Omit the the 'pem:' prefix"
    condition = anytrue([
      length(var.hmz_vault_trusted_sig) == 0,
      !can(regex("^pem:", var.hmz_vault_trusted_sig)),
    ])
  }
}

variable "hmz_vault_id" {
  type        = string
  description = "UUID of the Vault (Environment Variable VAULT_ID)."

  validation {
    error_message = "Value must be and UUID (36 hex or - characters)."
    condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", var.hmz_vault_id))
  }
}
