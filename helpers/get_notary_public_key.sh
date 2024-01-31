#!/bin/bash

command -v jq &> /dev/null || {
  echo "The jq command is missing" >&2
  exit 1
}

function usage() {
  echo "Usage: $0 -a <HMZ_API>" >&2
  exit 1
}

ARG_HMZ_API=""

while getopts ":a:" opt; do
  case $opt in
    a) ARG_HMZ_API="$OPTARG" ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$ARG_HMZ_API" ]; then
  usage
fi

export HMZ_URL_API_ENDPOINT_NOTARY_PUBLIC_KEY="$ARG_HMZ_API/internal/v1/system/information"

function get_notary_public_key() {

  echo "Retrieving Notary Public Key..." >&2
  echo "Calling Harmonize API @ $HMZ_URL_API_ENDPOINT_NOTARY_PUBLIC_KEY" >&2

  http_response=$(
    curl \
      --location -g \
      --request GET \
      --url "$HMZ_URL_API_ENDPOINT_NOTARY_PUBLIC_KEY"
  )

  echo "HTTP Request response: $http_response" >&2

  NOTARY_MESSAGING_PUB_KEY=$(
    echo -n "$http_response" | jq -r '.notary.messagingPublicKey'
  )

  echo -n "$NOTARY_MESSAGING_PUB_KEY"
}

retrieved_notary_public_key=$(get_notary_public_key)

if [ -n "$retrieved_notary_public_key" ]; then
  echo "Notary Public Key (base64): $retrieved_notary_public_key" >&2
else
  echo "Could not retrieve Notary Public Key" >&2
fi
