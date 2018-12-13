#!/bin/sh
## Imports given definition into CCD definition store.
##
## Usage: ./import-definition.sh path_to_definition userToken
##
## Prerequisites:
##  - Microservice `bulk_scan_orchestrator` must be authorised to call service `ccd-definition-store-api`

if [ -z "$1" ]
  then
    echo "Usage: ./import-definition.sh path_to_definition  user_token  auth_provider_api_base_url  microservice  ccd_store_api_base_url"
    exit 1
elif [ ! -f "$1" ]
  then
    echo "File not found: $1"
    exit 1
fi

userToken=$2
authProviderApi=$3
microservice=$4
ccdStoreApi=$5

serviceToken=$(curl --silent -X POST ${authProviderApi}/testing-support/lease -d \"{"microservice":"${microservice}"}\" -H 'content-type: application/json')

curl ${CURL_OPTS}  \
  ${ccdStoreApi}/import \
  -H "Authorization: Bearer ${userToken}" \
  -H "ServiceAuthorization: Bearer ${serviceToken}" \
  -F file="@$1"
