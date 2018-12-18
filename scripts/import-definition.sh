#!/bin/sh
## Imports given definition into CCD definition store.
##
## Usage: ./import-definition.sh path_to_definition user_token service_token ccd_store_api
##
## Prerequisites:
##  - Microservice  must be authorised to call service `ccd-definition-store-api`

if [ -z "$1" ]
  then
    echo "Usage: ./import-definition.sh  path_to_definition  user_token  service_token  ccd_store_api_base_url"
    exit 1
elif [ ! -f "$1" ]
  then
    echo "File not found: $1"
    exit 1
fi

userToken=$2
serviceToken=$3
ccdStoreApi=$4

curl ${CURL_OPTS}  \
  ${ccdStoreApi}/import \
  -H "Authorization: Bearer ${userToken}" \
  -H "ServiceAuthorization: Bearer ${serviceToken}" \
  -F file="@$1"
