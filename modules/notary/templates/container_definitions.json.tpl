[
  {
    "name": "notary",
    "image": "${hmz_notary_oci_image}:${hmz_notary_oci_tag}",
    "cpu": 2048,
    "memory": 4096,
    "essential": true,
    "repositoryCredentials": {
      credentialsParameter:
    }
    "environment": ${jsonencode(hmz_notary_environment_variables)},
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "mountPoints": [
      {
      "sourceVolume": "hmz-notary-anti-rewind-file-volume"
      "containerPath": "/data/anti-rewind"
      "readOnly": false
      },
      {
      "sourceVolume": "hmz-notary-tmp-folder-volume"
      "containerPath": "/tmp"
      "readOnly": false
      },
    ]
  },
  {
    "name": "kms",
    "image": "${hmz_kms_oci_image}:${hmz_kms_oci_tag}",
    "cpu": 2048,
    "memory": 4096,
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
