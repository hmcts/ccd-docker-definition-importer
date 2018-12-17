#!/bin/sh
## Add user role in ccd
##
## Usage: ./add-ccd-role.sh roles classification user_token service_token definition_store_api
##
## Options:
##    - roles: Names of the roles. Must be an existing IDAM role. Comma-separated values.
##    - classification: Classification granted to the role;
#          one of `PUBLIC`, `PRIVATE` or `RESTRICTED`. Default to `PUBLIC`.
##    - userToken: IDAM user auth token
##
## Add support for an IDAM role in CCD.

roles=$1
classification=$2
userToken=$3
serviceToken=$4
ccdStoreApi=$5

if [ "$#" -ne 4 ]
  then
    echo "Usage: ./add-ccd-role.sh roles classification user_token definition_store_api"
    exit 1
fi

case $classification in
  PUBLIC|PRIVATE|RESTRICTED)
    ;;
  *)
    echo "Classification must be one of: PUBLIC, PRIVATE or RESTRICTED"
    exit 1 ;;
esac

IFS=","
for role in roles
do
  curl ${CURL_OPTS} -XPUT \
    ${ccdStoreApi}/api/user-role \
    -H "Authorization: Bearer ${userToken}" \
    -H "ServiceAuthorization: Bearer ${serviceToken}" \
    -H "Content-Type: application/json" \
    -d '{"role":"'${role}'","security_classification":"'${classification}'"}'
done