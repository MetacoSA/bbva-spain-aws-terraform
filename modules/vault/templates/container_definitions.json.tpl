[
  {
    "name": "vault",
    "image": "${hmz_vault_oci_image}:${hmz_vault_oci_tag}",
    "cpu": 128,
    "memory": 256,
    "essential": true,
    "repositoryCredentials": {
      credentialsParameter:
    }
    "environment": ${jsonencode(hmz_vault_environment_variables)},
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "mountPoints": [
      {
      "sourceVolume": "hmz-vault-anti-rewind-file-volume"
      "containerPath": "/data/anti-rewind"
      "readOnly": false
      },
      {
      "sourceVolume": "hmz-vault-tmp-folder-volume"
      "containerPath": "/tmp"
      "readOnly": false
      },
    ]
  },
  {
    "name": "kms",
    "image": "${hmz_kms_oci_image}:${hmz_kms_oci_tag}",
    "cpu": 128,
    "memory": 256,
    "essential": true,
    "entryPoint": ["/bin/sh", "-c"]
    "command": [
      "mkdir -p /opt/kms/cfg && echo 'master = [KMS_SOFT_MASTER]' > /opt/kms/cfg/soft.cfg && chmod 444 /opt/kms/cfg/soft.cfg && exec /usr/bin/kms"
    ]
    "environment": ${jsonencode(hmz_kms_environment_variables)},
    "portMappings": [
      {
        "containerPort": 10000,
        "hostPort": 10000
      }
    ]
  }
]
