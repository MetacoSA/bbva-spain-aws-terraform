<!-- BEGIN_TF_DOCS -->
# About

Module for the Vault

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.ecs_secrets_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_secrets_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.hmz_kms_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.hmz_vault_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.hmz_kms_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.hmz_vault_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_pet.random_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_subnet.hmz_trusted_components_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.aws_vpc_hmz_trusted_components](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloud_watch_logs_group"></a> [aws\_cloud\_watch\_logs\_group](#input\_aws\_cloud\_watch\_logs\_group) | AWS CloudWatch Logs Group | `string` | `""` | no |
| <a name="input_aws_cloud_watch_logs_region"></a> [aws\_cloud\_watch\_logs\_region](#input\_aws\_cloud\_watch\_logs\_region) | AWS CloudWatch Logs Region | `string` | `""` | no |
| <a name="input_aws_cloud_watch_logs_stream_prefix"></a> [aws\_cloud\_watch\_logs\_stream\_prefix](#input\_aws\_cloud\_watch\_logs\_stream\_prefix) | AWS CloudWatch Logs Stream Prefix | `string` | `"hmz-trusted-components"` | no |
| <a name="input_aws_iam_role_ecs_task_role_arn"></a> [aws\_iam\_role\_ecs\_task\_role\_arn](#input\_aws\_iam\_role\_ecs\_task\_role\_arn) | AWS IAM Role ARN for ECS Task | `string` | n/a | yes |
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | A map of labels to be applied to the resource. | `map(string)` | `{}` | no |
| <a name="input_aws_subnet_id"></a> [aws\_subnet\_id](#input\_aws\_subnet\_id) | AWS Subnet ID | `string` | n/a | yes |
| <a name="input_aws_vpc_cidr"></a> [aws\_vpc\_cidr](#input\_aws\_vpc\_cidr) | AWS VPC CIDR block for Security Group HMZ Vault Anti-Rewind file | `string` | n/a | yes |
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | AWS VPC ID for Security Group HMZ Vault Anti-Rewind file | `string` | n/a | yes |
| <a name="input_hmz_kms_connect_software_master_key"></a> [hmz\_kms\_connect\_software\_master\_key](#input\_hmz\_kms\_connect\_software\_master\_key) | Software KMS Master Key. (Environment Variable HMZ\_KMS\_CONNECT\_SOFTWARE\_MASTER\_KEY, e.g. HMZ\_KMS\_CONNECT\_SOFTWARE\_MASTER\_KEY='79acc37afb7b2e0da4afb3a350ce49b73a24555431b0211dbf0bf93886c0fbff') | `string` | n/a | yes |
| <a name="input_hmz_kms_container_registry_password"></a> [hmz\_kms\_container\_registry\_password](#input\_hmz\_kms\_container\_registry\_password) | KMS Container Registry Password | `string` | n/a | yes |
| <a name="input_hmz_kms_container_registry_user"></a> [hmz\_kms\_container\_registry\_user](#input\_hmz\_kms\_container\_registry\_user) | KMS Container Registry User | `string` | n/a | yes |
| <a name="input_hmz_kms_oci_image"></a> [hmz\_kms\_oci\_image](#input\_hmz\_kms\_oci\_image) | KMS Connect OCI Image | `string` | `"metaco.azurecr.io/harmonize/kms-soft"` | no |
| <a name="input_hmz_kms_oci_tag"></a> [hmz\_kms\_oci\_tag](#input\_hmz\_kms\_oci\_tag) | KMS Connect OCI Tag | `string` | n/a | yes |
| <a name="input_hmz_vault_bridge_log_level"></a> [hmz\_vault\_bridge\_log\_level](#input\_hmz\_vault\_bridge\_log\_level) | HMZ Vault Environment Variable VAULT\_BRIDGE\_LOGLEVEL | `number` | `6` | no |
| <a name="input_hmz_vault_container_registry_password"></a> [hmz\_vault\_container\_registry\_password](#input\_hmz\_vault\_container\_registry\_password) | HMZ Vault Container Registry Password | `string` | n/a | yes |
| <a name="input_hmz_vault_container_registry_user"></a> [hmz\_vault\_container\_registry\_user](#input\_hmz\_vault\_container\_registry\_user) | HMZ Vault Container Registry User | `string` | n/a | yes |
| <a name="input_hmz_vault_feature_otlp_in_stdout"></a> [hmz\_vault\_feature\_otlp\_in\_stdout](#input\_hmz\_vault\_feature\_otlp\_in\_stdout) | HMZ Vault Environment Variable HMZ\_FEATURE\_OTLP\_IN\_STDOUT (Display logs in JSON format) | `bool` | `false` | no |
| <a name="input_hmz_vault_harmonize_core_endpoint"></a> [hmz\_vault\_harmonize\_core\_endpoint](#input\_hmz\_vault\_harmonize\_core\_endpoint) | HMZ Vault Environment Variable HARMONIZE\_CORE\_ENDPOINT (Vault Core Endpoint) | `string` | n/a | yes |
| <a name="input_hmz_vault_id"></a> [hmz\_vault\_id](#input\_hmz\_vault\_id) | UUID of the Vault (Environment Variable VAULT\_ID). | `string` | n/a | yes |
| <a name="input_hmz_vault_log_level"></a> [hmz\_vault\_log\_level](#input\_hmz\_vault\_log\_level) | HMZ Vault Environment Variable VAULT\_LOGLEVEL | `number` | `6` | no |
| <a name="input_hmz_vault_oci_image"></a> [hmz\_vault\_oci\_image](#input\_hmz\_vault\_oci\_image) | HMZ Vault Connect OCI Image | `string` | `"metaco.azurecr.io/harmonize/vault-releases"` | no |
| <a name="input_hmz_vault_oci_tag"></a> [hmz\_vault\_oci\_tag](#input\_hmz\_vault\_oci\_tag) | HMZ Vault Connect OCI Tag | `string` | n/a | yes |
| <a name="input_hmz_vault_optional_maximum_fee"></a> [hmz\_vault\_optional\_maximum\_fee](#input\_hmz\_vault\_optional\_maximum\_fee) | HMZ Vault Environment Variable HMZ\_OPTIONAL\_MAXIMUM\_FEE | `bool` | `false` | no |
| <a name="input_hmz_vault_trusted_notary_messaging_public_key"></a> [hmz\_vault\_trusted\_notary\_messaging\_public\_key](#input\_hmz\_vault\_trusted\_notary\_messaging\_public\_key) | System (Vault) public key, which is listed as part of the first system event confirming the genesis execution (Environment Variable HMZ\_VAULT\_TRUSTED\_NOTARY\_MESSAGING\_PUBLIC\_KEY, without the 'pem:' at the beginning). | `string` | `""` | no |
| <a name="input_random_pet"></a> [random\_pet](#input\_random\_pet) | Random Pet | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_task_definition"></a> [ecs\_task\_definition](#output\_ecs\_task\_definition) | The entire ECS task definition |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | The ARN of the ECS task definition |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | The family of the ECS task definition |
<!-- END_TF_DOCS -->