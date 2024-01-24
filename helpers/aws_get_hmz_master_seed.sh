#!/bin/bash

command -v jq &> /dev/null || {
  echo "The jq command is missing" >&2
  exit 1
}
command -v podman &> /dev/null || {
  echo "The podman command is missing" >&2
  exit 1
}

# Function definitions for podman calls
function pull_oci_image() {
  echo 'Pulling OCI Image docker.io/amazon/aws-cli' >&2
  sudo podman pull docker.io/amazon/aws-cli
  echo 'Pull done.' >&2
}

function get_master_seed_secret_json() {
  echo "Fetching the master seed from AWS Secrets Manager (ARN: $1)" >&2
  output=$(
    sudo podman run --rm -i docker.io/amazon/aws-cli secretsmanager get-secret-value --secret-id "$1" --query 'SecretString' --output text
  )
  echo "Fetch done." >&2
  echo -n "$output"
}

function store_wrapped_seed() {
  echo "Storing the wrapped seed in AWS Secrets Manager (Secret ID: $1) (JSON Key Field: $2)" >&2
  output=$(
    sudo podman run --rm -i docker.io/amazon/aws-cli secretsmanager put-secret-value --secret-id "$1" --secret-string "{\"$2\": \"$3\"}"
  )
  echo "Storage done." >&2
  echo -n "$output"
}

function generate_random_master_seed() {
  echo 'Generating a new random master seed using AWS KMS' >&2
  output=$(
    sudo podman run --rm -i docker.io/amazon/aws-cli kms generate-random --number-of-bytes 32 --output text --query Plaintext | base64 --decode | xxd -p -c 32
  )
  echo 'Generation done.' >&2
  echo -n "$output"

}

function wrap_master_seed() {
  echo "Wrapping the master seed using AWS KMS (KMS Key ID: $2)" >&2
  output=$(
    echo -n "$1" | sudo podman run --rm -i docker.io/amazon/aws-cli kms encrypt --key-id "$2" --plaintext fileb:///dev/stdin --output text --query CiphertextBlob
  )
  echo "Wrapping done." >&2
  echo -n "$output"
}

function unwrap_master_seed() {
  echo "Unwrapping the master seed using AWS KMS (KMS Key ID: $2)" >&2
  output=$(
    echo "$1" | base64 --decode | sudo podman run --rm -i docker.io/amazon/aws-cli kms decrypt --ciphertext-blob fileb:///dev/stdin --key-id "$2" --query Plaintext --output text | base64 --decode
  )
  echo "Unwrapping done." >&2
  echo -n "$output"
}

# Default values
aws_secret_manager_hmz_wrapped_master_seed_arn=""
hmz_wrapped_master_seed_json_field_key=""
aws_kms_key_hmz_master_seed_wrapper_id=""
output_file_path=""

# Parse options
while getopts ":s:j:k:o:" opt; do
  case $opt in
    s)
      aws_secret_manager_hmz_wrapped_master_seed_arn="$OPTARG"
      ;;
    j)
      hmz_wrapped_master_seed_json_field_key="$OPTARG"
      ;;
    k)
      aws_kms_key_hmz_master_seed_wrapper_id="$OPTARG"
      ;;
    o)
      output_file_path="$OPTARG"
      ;;
    \?)
      echo "Invalid option -$OPTARG" >&2
      ;;
  esac
done

# Check if required options are provided
if [ -z "$aws_secret_manager_hmz_wrapped_master_seed_arn" ] || [ -z "$hmz_wrapped_master_seed_json_field_key" ] || [ -z "$aws_kms_key_hmz_master_seed_wrapper_id" ] || [ -z "$output_file_path" ]; then
  echo "Usage: $0 -s aws-secret-arn -j json-field-key -k aws-kms-key-id -o output-file" >&2
  exit 1
fi

echo "Script $0 starts." >&2

pull_oci_image

retrieved_wrapped_master_seed_json=$(get_master_seed_secret_json "$aws_secret_manager_hmz_wrapped_master_seed_arn")
wrapped_master_seed=$(echo -n "$retrieved_wrapped_master_seed_json" | jq -r ".$hmz_wrapped_master_seed_json_field_key")

unwrapped_master_seed=""

if [ -z "$wrapped_master_seed" ]; then
  echo 'Wrapped Master seed does not exist in AWS Secrets Manager' >&2

  unwrapped_master_seed=$(generate_random_master_seed)
  wrapped_master_seed=$(wrap_master_seed "$unwrapped_master_seed" "$aws_kms_key_hmz_master_seed_wrapper_id")
  store_secret_request_result=$(store_wrapped_seed "$aws_secret_manager_hmz_wrapped_master_seed_arn" "$hmz_wrapped_master_seed_json_field_key" "$wrapped_master_seed")

  echo "$store_secret_request_result" >&2

else
  echo 'Wrapped Master seed already exists in AWS Secrets Manager' >&2
  unwrapped_master_seed=$(unwrap_master_seed "$wrapped_master_seed" "$aws_kms_key_hmz_master_seed_wrapper_id")
fi

echo "Writing Unwrapped Master in file system @ $output_file_path" >&2
echo "$unwrapped_master_seed" | sudo tee "$output_file_path" > /dev/null
echo "Writing Done." >&2

echo "Script $0 finished." >&2

# echo "Master Seed Clear Text ($unwrapped_master_seed)" >&2
