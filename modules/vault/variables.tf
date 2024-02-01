variable "random_pet" {
  description = "Random Pet"
  type        = string
  default     = ""
}

# AWS config

variable "aws_vpc_id" {
  description = "AWS VPC ID for Security Group HMZ Vault Anti-Rewind file"
  type        = string


  validation {
    condition     = can(regex("^vpc-[a-fA-F0-9]{17}$", var.aws_vpc_id))
    error_message = "The AWS VPC ID must be in the format 'vpc-xxxxxxxxxxxxxxxxx'."
  }
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR block for Security Group HMZ Vault Anti-Rewind file"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.aws_vpc_cidr))
    error_message = "The AWS VPC CIDR block is not in the correct format. Expected format is x.x.x.x/y."
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
  default     = "hmz-trusted-components"
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
  description = "HMZ Vault Connect OCI Image"

  validation {
    condition     = length(var.hmz_vault_oci_image) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_oci_tag" {
  type        = string
  description = "HMZ Vault Connect OCI Tag"

  validation {
    condition     = length(var.hmz_vault_oci_tag) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_container_registry_user" {
  type        = string
  sensitive   = true
  description = "HMZ Vault Container Registry User"

  validation {
    condition     = length(var.hmz_vault_container_registry_user) > 0
    error_message = "Must non empty string"
  }
}

variable "hmz_vault_container_registry_password" {
  type        = string
  sensitive   = true
  description = "HMZ Vault Container Registry Password"

  validation {
    condition     = length(var.hmz_vault_container_registry_password) > 0
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


# HMZ Vault Environment Variables

variable "hmz_vault_feature_otlp_in_stdout" {
  type        = bool
  default     = false
  description = "HMZ Vault Environment Variable HMZ_FEATURE_OTLP_IN_STDOUT (Display logs in JSON format)"
}

variable "hmz_vault_log_level" {
  type        = number
  default     = 6
  description = "HMZ Vault Environment Variable VAULT_LOGLEVEL"

  validation {
    condition     = contains([3, 4, 6, 7], var.hmz_vault_log_level)
    error_message = "The hmz_vault_log_level must be one of the specified integers (3=error, 4=warning, 6=info, 7=debug)."
  }
}

variable "hmz_vault_bridge_log_level" {
  type        = number
  default     = 6
  description = "HMZ Vault Environment Variable VAULT_BRIDGE_LOGLEVEL"

  validation {
    condition     = contains([3, 4, 6, 7], var.hmz_vault_bridge_log_level)
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
  description = "System (Vault) public key, which is listed as part of the first system event confirming the genesis execution (Environment Variable HMZ_VAULT_TRUSTED_NOTARY_MESSAGING_PUBLIC_KEY, without the 'pem:' at the beginning)."

  validation {
    error_message = "Value must be empty or it must be a base64 encoded public key. Omit the the 'pem:' prefix"
    condition = anytrue([
      length(var.hmz_vault_trusted_notary_messaging_public_key) == 0,
      !can(regex("^pem:", var.hmz_vault_trusted_notary_messaging_public_key)),
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


variable "hmz_vault_optional_maximum_fee" {
  type        = bool
  default     = false
  description = "HMZ Vault Environment Variable HMZ_OPTIONAL_MAXIMUM_FEE"
}
