<!-- BEGIN_TF_DOCS -->
# About

Module for the Notary

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
| [aws_efs_file_system.hmz_notary_anti_rewind_file_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system.hmz_notary_tmp_folder_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.hmz_notary_anti_rewind_file_efs_mt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_mount_target.hmz_notary_tmp_efs_mt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_policy.ecs_secrets_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_secrets_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.hmz_kms_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.hmz_notary_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.hmz_kms_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.hmz_notary_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.efs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_pet.random_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_subnet.hmz_trusted_components_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.aws_vpc_hmz_trusted_components](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloud_watch_logs_group"></a> [aws\_cloud\_watch\_logs\_group](#input\_aws\_cloud\_watch\_logs\_group) | AWS CloudWatch Logs Group | `string` | `""` | no |
| <a name="input_aws_cloud_watch_logs_region"></a> [aws\_cloud\_watch\_logs\_region](#input\_aws\_cloud\_watch\_logs\_region) | AWS CloudWatch Logs Region | `string` | `""` | no |
| <a name="input_aws_cloud_watch_logs_stream_prefix"></a> [aws\_cloud\_watch\_logs\_stream\_prefix](#input\_aws\_cloud\_watch\_logs\_stream\_prefix) | AWS CloudWatch Logs Stream Prefix | `string` | `""` | no |
| <a name="input_aws_iam_role_ecs_task_role_arn"></a> [aws\_iam\_role\_ecs\_task\_role\_arn](#input\_aws\_iam\_role\_ecs\_task\_role\_arn) | AWS IAM Role ARN for ECS Task | `string` | n/a | yes |
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | A map of labels to be applied to the resource. | `map(string)` | `{}` | no |
| <a name="input_aws_subnet_id"></a> [aws\_subnet\_id](#input\_aws\_subnet\_id) | AWS Subnet ID | `string` | n/a | yes |
| <a name="input_aws_vpc_cidr"></a> [aws\_vpc\_cidr](#input\_aws\_vpc\_cidr) | AWS VPC CIDR block | `string` | n/a | yes |
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | AWS VPC ID | `string` | n/a | yes |
| <a name="input_hmz_kms_connect_software_master_key"></a> [hmz\_kms\_connect\_software\_master\_key](#input\_hmz\_kms\_connect\_software\_master\_key) | Software KMS Master Key. (Environment Variable HMZ\_KMS\_CONNECT\_SOFTWARE\_MASTER\_KEY, e.g. HMZ\_KMS\_CONNECT\_SOFTWARE\_MASTER\_KEY='79acc37afb7b2e0da4afb3a350ce49b73a24555431b0211dbf0bf93886c0fbff') | `string` | n/a | yes |
| <a name="input_hmz_kms_container_registry_password"></a> [hmz\_kms\_container\_registry\_password](#input\_hmz\_kms\_container\_registry\_password) | KMS Container Registry Password | `string` | n/a | yes |
| <a name="input_hmz_kms_container_registry_user"></a> [hmz\_kms\_container\_registry\_user](#input\_hmz\_kms\_container\_registry\_user) | KMS Container Registry User | `string` | n/a | yes |
| <a name="input_hmz_kms_oci_image"></a> [hmz\_kms\_oci\_image](#input\_hmz\_kms\_oci\_image) | KMS Connect OCI Image | `string` | `"metaco.azurecr.io/harmonize/kms-soft"` | no |
| <a name="input_hmz_kms_oci_tag"></a> [hmz\_kms\_oci\_tag](#input\_hmz\_kms\_oci\_tag) | KMS Connect OCI Tag | `string` | n/a | yes |
| <a name="input_hmz_notary_bridge_http_endpoint"></a> [hmz\_notary\_bridge\_http\_endpoint](#input\_hmz\_notary\_bridge\_http\_endpoint) | Harmonize notary bridge API endpoint | `string` | n/a | yes |
| <a name="input_hmz_notary_cols_dir"></a> [hmz\_notary\_cols\_dir](#input\_hmz\_notary\_cols\_dir) | Notary storage folder of the Anti-Rewind File (Environment Variable HMZ\_NOTARY\_COLS\_DIR) | `string` | `"/data/anti-rewind"` | no |
| <a name="input_hmz_notary_container_registry_password"></a> [hmz\_notary\_container\_registry\_password](#input\_hmz\_notary\_container\_registry\_password) | Notary Container Registry Password | `string` | n/a | yes |
| <a name="input_hmz_notary_container_registry_user"></a> [hmz\_notary\_container\_registry\_user](#input\_hmz\_notary\_container\_registry\_user) | Notary Container Registry User | `string` | n/a | yes |
| <a name="input_hmz_notary_grpc_enabled"></a> [hmz\_notary\_grpc\_enabled](#input\_hmz\_notary\_grpc\_enabled) | Enables grpc communication with the notary bridge | `bool` | `false` | no |
| <a name="input_hmz_notary_hc_tracing_enabled"></a> [hmz\_notary\_hc\_tracing\_enabled](#input\_hmz\_notary\_hc\_tracing\_enabled) | Notary enables or disables Health Check Tracing (Environment Variable HMZ\_HC\_TRACING\_ENABLED) | `bool` | `false` | no |
| <a name="input_hmz_notary_http_enabled"></a> [hmz\_notary\_http\_enabled](#input\_hmz\_notary\_http\_enabled) | Enables http communication with the notary bridge | `bool` | `true` | no |
| <a name="input_hmz_notary_kms_grpc_keep_alive_interval"></a> [hmz\_notary\_kms\_grpc\_keep\_alive\_interval](#input\_hmz\_notary\_kms\_grpc\_keep\_alive\_interval) | Notary gRPC connection to KMS Connect: Keep alive interval in seconds | `number` | `10` | no |
| <a name="input_hmz_notary_kms_grpc_keep_alive_timeout"></a> [hmz\_notary\_kms\_grpc\_keep\_alive\_timeout](#input\_hmz\_notary\_kms\_grpc\_keep\_alive\_timeout) | Notary gRPC connection to KMS Connect: Keep alive timeout in seconds | `number` | `10` | no |
| <a name="input_hmz_notary_log_level"></a> [hmz\_notary\_log\_level](#input\_hmz\_notary\_log\_level) | Logging level | `string` | `"INFO"` | no |
| <a name="input_hmz_notary_oci_image"></a> [hmz\_notary\_oci\_image](#input\_hmz\_notary\_oci\_image) | Notary OCI Image | `string` | `"metaco.azurecr.io/harmonize/approval-notary"` | no |
| <a name="input_hmz_notary_oci_tag"></a> [hmz\_notary\_oci\_tag](#input\_hmz\_notary\_oci\_tag) | Notary OCI Tag | `string` | n/a | yes |
| <a name="input_hmz_notary_open_telemetry_type"></a> [hmz\_notary\_open\_telemetry\_type](#input\_hmz\_notary\_open\_telemetry\_type) | Notary type of Telemetry (Environment Variable HMZ\_OPEN\_TELEMETRY\_TYPE) | `string` | `"disabled"` | no |
| <a name="input_hmz_notary_otel_sdk_disabled"></a> [hmz\_notary\_otel\_sdk\_disabled](#input\_hmz\_notary\_otel\_sdk\_disabled) | Notary enables or disables Open Telemetry SDK (Environment Variable OTEL\_SDK\_DISABLED) | `bool` | `true` | no |
| <a name="input_hmz_notary_state_manifest_file_path"></a> [hmz\_notary\_state\_manifest\_file\_path](#input\_hmz\_notary\_state\_manifest\_file\_path) | Path to manifest.json file that contains the Anti-Rewind state manifest | `string` | `"manifest.json"` | no |
| <a name="input_hmz_notary_state_manifest_signature"></a> [hmz\_notary\_state\_manifest\_signature](#input\_hmz\_notary\_state\_manifest\_signature) | HMZ Notary Anti-Rewind state manifest signature (Disaster Recovery Procedure) | `string` | `""` | no |
| <a name="input_random_pet"></a> [random\_pet](#input\_random\_pet) | Random Pet | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_task_definition"></a> [ecs\_task\_definition](#output\_ecs\_task\_definition) | The entire ECS task definition |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | The ARN of the ECS task definition |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | The family of the ECS task definition |
<!-- END_TF_DOCS -->