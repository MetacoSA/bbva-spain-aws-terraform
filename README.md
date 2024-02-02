<!-- BEGIN_TF_DOCS -->
# Metaco Harmonize Trusted Components Terraform Scripts for AWS ECS

This project simplifies the creation and update of AWS ECS over Fargate,
hosting Harmonize Trusted Components with a software HMZ KMS provider.

Request information to our Customer success team to become familiar with
the software HMZ KMS provider.

## Required Dependencies

To get started, install all required dependencies on the host machine.

### Check versions

To check `terraform` version, run `terraform version`:

Example output:

```bash
Terraform v1.6.3
on darwin_arm64
+ provider registry.terraform.io/hashicorp/aws v5.26.0
+ provider registry.terraform.io/hashicorp/random v2.3.2
```

Initialize the Terraform scripts:

```bash
terraform init
```

### Local configuration

The Terraform scripts uses two configuration files:

- `.env` file (for AWS Credentials)
- `tfvars.terraform` file (for deployment parameters)

Copy the provided sample configuration files

```bash
cp .env.sample .env
cp terraform.tfvars.sample terraform.tfvars
```

### AWS Credentials

Fill the environment variables file with you AWS Account credentials

```bash
export AWS_ACCESS_KEY_ID='<YOUR_AWS_ACCESS_KEY>'
export AWS_SECRET_ACCESS_KEY='<YOUR_AWS_ACCESS_KEY>'
```

The [official AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) provide detailed steps to create an AWS Access Key.
An AWS Access Key can be created for the root user by [following this documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user_manage_add-key.html).

### Metaco Container Registry Credentials

Retrieve the provided Metaco Container Registry Credentials (user and password) and fill the `tfvars.terraform` file.

### Harmonize Version

The OCI (Open Container Initiative) tags MUST be provided in the file `tfvars.terraform` for the following HMZ Trusted Components:

- Harmonize KMS Connect
- Harmonize Notary
- Harmonize Vault

### Harmonize SaaS instance endpoints

Retrieve the provided dedicated Harmonize endpoint:

- Harmonize Core API endpoint (for the Vault)
- Harmonize Notary Bridge endpoint (for the Notary)

The `tfvars.terraform` file MUST be filled with those values.

### Harmonize Vault Config

For each Harmonize Vault instance, fill the values:

- Vault ID
- Vault Log Level
- Vault Bridge Log Level
- Vault Trusted Notary Messaging Public Key (retrieved after Genesis is executed successfully)

#### Notary Message Public Key retrieval

First apply the Genesis against the Harmonize API (HTTP POST request @ /v1/genesis)

```bash
curl -s \
    --location -g \
    --request POST "$HMZ_URL_API/v1/genesis" \
    --header 'Content-Type: application/json' \
    --data @"$FILE_NAME_GENESIS_CONFIG_JSON"
```

Then, after a successful Genesis application, fetch from the Harmonize API,
the Notary Messaging Public Key:

```bash
curl \
    --location -g \
    --request GET \
    --url "$HMZ_URL_API/internal/v1/system/information"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_notary"></a> [notary](#module\_notary) | ./modules/notary | n/a |
| <a name="module_vault"></a> [vault](#module\_vault) | ./modules/vault | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_role.ecs_task_role_for_hmz_trusted_components](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.hmz_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.hmz_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.ecs_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_pet.random_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_ecs_cluster.aws_ecs_cluster_for_hmz_trusted_components](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_secretsmanager_secret.hmz_oci_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_security_group.hmz_trusted_components_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_subnet.hmz_trusted_components_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.aws_vpc_hmz_trusted_components](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloud_watch_logs_group"></a> [aws\_cloud\_watch\_logs\_group](#input\_aws\_cloud\_watch\_logs\_group) | AWS CloudWatch Logs Group | `string` | `""` | no |
| <a name="input_aws_cloud_watch_logs_region"></a> [aws\_cloud\_watch\_logs\_region](#input\_aws\_cloud\_watch\_logs\_region) | AWS CloudWatch Logs Region | `string` | `""` | no |
| <a name="input_aws_cloud_watch_logs_stream_prefix"></a> [aws\_cloud\_watch\_logs\_stream\_prefix](#input\_aws\_cloud\_watch\_logs\_stream\_prefix) | AWS CloudWatch Logs Stream Prefix | `string` | `""` | no |
| <a name="input_aws_ecs_cluster_name"></a> [aws\_ecs\_cluster\_name](#input\_aws\_ecs\_cluster\_name) | AWS ECS Cluster Name | `string` | `""` | no |
| <a name="input_aws_enable_vpc_creation"></a> [aws\_enable\_vpc\_creation](#input\_aws\_enable\_vpc\_creation) | Set this flag to true to enable AWS VPC Creation | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where Cloud resources will be deployed | `string` | n/a | yes |
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | A map of labels to be applied to the resource ('Name' or 'name' keys excluded). | `map(string)` | `{}` | no |
| <a name="input_aws_secrets_manager_arn_for_hmz_oci_registry_credentials"></a> [aws\_secrets\_manager\_arn\_for\_hmz\_oci\_registry\_credentials](#input\_aws\_secrets\_manager\_arn\_for\_hmz\_oci\_registry\_credentials) | AWS Secrets Manager Secret ARN for Harmonize OCI registry credentials | `string` | `""` | no |
| <a name="input_aws_security_group_id"></a> [aws\_security\_group\_id](#input\_aws\_security\_group\_id) | AWS Security Group ID | `string` | `""` | no |
| <a name="input_aws_subnet_id"></a> [aws\_subnet\_id](#input\_aws\_subnet\_id) | AWS Subnet ID | `string` | `""` | no |
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | AWS VPC ID for Security Group HMZ Notary Anti-Rewind file | `string` | `""` | no |
| <a name="input_hmz_kms_connect_software_master_key"></a> [hmz\_kms\_connect\_software\_master\_key](#input\_hmz\_kms\_connect\_software\_master\_key) | HMZ KMS Connect Software Master Key (hexadecimal). (Environment Variable HMZ\_KMS\_CONNECT\_SOFTWARE\_MASTER\_KEY, e.g. HMZ\_KMS\_CONNECT\_SOFTWARE\_MASTER\_KEY='79acc37afb7b2e0da4afb3a350ce49b73a24555431b0211dbf0bf93886c0fbff') | `string` | `""` | no |
| <a name="input_hmz_kms_container_registry_password"></a> [hmz\_kms\_container\_registry\_password](#input\_hmz\_kms\_container\_registry\_password) | HMZ KMS Connect Container Registry Password | `string` | `null` | no |
| <a name="input_hmz_kms_container_registry_user"></a> [hmz\_kms\_container\_registry\_user](#input\_hmz\_kms\_container\_registry\_user) | HMZ KMS Connect Container Registry User | `string` | `null` | no |
| <a name="input_hmz_kms_oci_image"></a> [hmz\_kms\_oci\_image](#input\_hmz\_kms\_oci\_image) | HMZ KMS Connect OCI Image | `string` | `"metaco.azurecr.io/harmonize/kms-soft"` | no |
| <a name="input_hmz_kms_oci_tag"></a> [hmz\_kms\_oci\_tag](#input\_hmz\_kms\_oci\_tag) | HMZ KMS Connect OCI Tag | `string` | n/a | yes |
| <a name="input_hmz_metaco_container_registry_password"></a> [hmz\_metaco\_container\_registry\_password](#input\_hmz\_metaco\_container\_registry\_password) | Metaco Container Registry Password | `string` | n/a | yes |
| <a name="input_hmz_metaco_container_registry_user"></a> [hmz\_metaco\_container\_registry\_user](#input\_hmz\_metaco\_container\_registry\_user) | Metaco Container Registry User | `string` | n/a | yes |
| <a name="input_hmz_notary_bridge_http_endpoint"></a> [hmz\_notary\_bridge\_http\_endpoint](#input\_hmz\_notary\_bridge\_http\_endpoint) | Harmonize Notary bridge API endpoint | `string` | n/a | yes |
| <a name="input_hmz_notary_cols_dir"></a> [hmz\_notary\_cols\_dir](#input\_hmz\_notary\_cols\_dir) | HMZ Notary storage folder of the Anti-Rewind File (Environment Variable HMZ\_NOTARY\_COLS\_DIR) | `string` | `"/data/anti-rewind"` | no |
| <a name="input_hmz_notary_container_registry_password"></a> [hmz\_notary\_container\_registry\_password](#input\_hmz\_notary\_container\_registry\_password) | HMZ Notary Container Registry Password | `string` | `null` | no |
| <a name="input_hmz_notary_container_registry_user"></a> [hmz\_notary\_container\_registry\_user](#input\_hmz\_notary\_container\_registry\_user) | HMZ Notary Container Registry User | `string` | `null` | no |
| <a name="input_hmz_notary_enabled"></a> [hmz\_notary\_enabled](#input\_hmz\_notary\_enabled) | Set this flag to true to enable Notary instance deployment. | `bool` | `false` | no |
| <a name="input_hmz_notary_grpc_enabled"></a> [hmz\_notary\_grpc\_enabled](#input\_hmz\_notary\_grpc\_enabled) | Enables grpc communication with the Notary Bridge | `bool` | `false` | no |
| <a name="input_hmz_notary_hc_tracing_enabled"></a> [hmz\_notary\_hc\_tracing\_enabled](#input\_hmz\_notary\_hc\_tracing\_enabled) | HMZ Notary enables or disables Health Check Tracing (Environment Variable HMZ\_HC\_TRACING\_ENABLED) | `bool` | `false` | no |
| <a name="input_hmz_notary_http_enabled"></a> [hmz\_notary\_http\_enabled](#input\_hmz\_notary\_http\_enabled) | Enables http communication with the Notary Bridge | `bool` | `true` | no |
| <a name="input_hmz_notary_kms_grpc_keep_alive_interval"></a> [hmz\_notary\_kms\_grpc\_keep\_alive\_interval](#input\_hmz\_notary\_kms\_grpc\_keep\_alive\_interval) | HMZ Notary gRPC connection to KMS Connect: Keep alive interval in seconds | `number` | `10` | no |
| <a name="input_hmz_notary_kms_grpc_keep_alive_timeout"></a> [hmz\_notary\_kms\_grpc\_keep\_alive\_timeout](#input\_hmz\_notary\_kms\_grpc\_keep\_alive\_timeout) | HMZ Notary gRPC connection to KMS Connect: Keep alive timeout in seconds | `number` | `10` | no |
| <a name="input_hmz_notary_log_level"></a> [hmz\_notary\_log\_level](#input\_hmz\_notary\_log\_level) | HMZ Notary Logging level | `string` | `"INFO"` | no |
| <a name="input_hmz_notary_oci_image"></a> [hmz\_notary\_oci\_image](#input\_hmz\_notary\_oci\_image) | HMZ Notary OCI Image | `string` | `"metaco.azurecr.io/harmonize/approval-notary"` | no |
| <a name="input_hmz_notary_oci_tag"></a> [hmz\_notary\_oci\_tag](#input\_hmz\_notary\_oci\_tag) | HMZ Notary OCI Tag | `string` | n/a | yes |
| <a name="input_hmz_notary_open_telemetry_type"></a> [hmz\_notary\_open\_telemetry\_type](#input\_hmz\_notary\_open\_telemetry\_type) | HMZ Notary type of Telemetry (Environment Variable HMZ\_OPEN\_TELEMETRY\_TYPE) | `string` | `"disabled"` | no |
| <a name="input_hmz_notary_otel_sdk_disabled"></a> [hmz\_notary\_otel\_sdk\_disabled](#input\_hmz\_notary\_otel\_sdk\_disabled) | HMZ Notary enables or disables Open Telemetry SDK (Environment Variable OTEL\_SDK\_DISABLED) | `bool` | `true` | no |
| <a name="input_hmz_notary_state_manifest_file_path"></a> [hmz\_notary\_state\_manifest\_file\_path](#input\_hmz\_notary\_state\_manifest\_file\_path) | Path to manifest.json file that contains the Anti-Rewind state manifest | `string` | `"manifest.json"` | no |
| <a name="input_hmz_notary_state_manifest_signature"></a> [hmz\_notary\_state\_manifest\_signature](#input\_hmz\_notary\_state\_manifest\_signature) | HMZ Notary Anti-Rewind state manifest signature (Disaster Recovery Procedure) | `string` | `""` | no |
| <a name="input_hmz_vault_container_registry_password"></a> [hmz\_vault\_container\_registry\_password](#input\_hmz\_vault\_container\_registry\_password) | HMZ Vault Container Registry Password | `string` | `null` | no |
| <a name="input_hmz_vault_container_registry_user"></a> [hmz\_vault\_container\_registry\_user](#input\_hmz\_vault\_container\_registry\_user) | HMZ Vault Container Registry User | `string` | `null` | no |
| <a name="input_hmz_vault_harmonize_core_endpoint"></a> [hmz\_vault\_harmonize\_core\_endpoint](#input\_hmz\_vault\_harmonize\_core\_endpoint) | HMZ Vault Environment Variable HARMONIZE\_CORE\_ENDPOINT (Vault Core Endpoint) | `string` | n/a | yes |
| <a name="input_hmz_vault_oci_image"></a> [hmz\_vault\_oci\_image](#input\_hmz\_vault\_oci\_image) | HMZ Vault OCI Image | `string` | `"metaco.azurecr.io/harmonize/vault-releases"` | no |
| <a name="input_hmz_vault_oci_tag"></a> [hmz\_vault\_oci\_tag](#input\_hmz\_vault\_oci\_tag) | HMZ Vault OCI Tag | `string` | n/a | yes |
| <a name="input_hmz_vault_trusted_notary_messaging_public_key"></a> [hmz\_vault\_trusted\_notary\_messaging\_public\_key](#input\_hmz\_vault\_trusted\_notary\_messaging\_public\_key) | System (Notary) public key, which is listed as part of the first system event confirming the genesis execution (Environment Variable HMZ\_VAULT\_TRUSTED\_NOTARY\_MESSAGING\_PUBLIC\_KEY, without the 'pem:' at the beginning). | `string` | `""` | no |
| <a name="input_vaults"></a> [vaults](#input\_vaults) | List of Vault instances. | <pre>list(object({<br>    hmz_vault_id                     = string<br>    hmz_vault_log_level              = number<br>    hmz_vault_bridge_log_level       = number<br>    hmz_vault_feature_otlp_in_stdout = bool<br>    hmz_vault_optional_maximum_fee   = bool<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->