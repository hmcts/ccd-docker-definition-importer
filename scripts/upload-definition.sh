#!/bin/sh
set -e

chmod +x /scripts/*.sh

[ "_${CCD_DEF_URLS}" = "_" ] && echo "No definitions to load from CCD_DEF_URLS. Script terminated." && exit 0

mkdir /definitions && cd /definitions

defs=$(echo "$CCD_DEF_URLS" | tr "," "\n")
for def in $defs
do
    wget -nd "$def"
    [ $? -ne 0 ] && "Failed to download \"${def}\". Script terminated." && exit 21
done
[ -z "$(ls -A /definitions)" ] && echo "No definitions found to download. Script terminated." && exit 22

if [ ${VERBOSE} = "true" ]; then
  export CURL_OPTS="-v"
else
  export CURL_OPTS="--fail --silent"
fi

if [ "_${IMPORTER_CREDS_MOUNT}" != "_" ]; then
  IMPORTER_USERNAME=$(cat ${IMPORTER_CREDS_MOUNT}/ccd-as-a-pr-importer-username)
  IMPORTER_PASSWORD=$(cat ${IMPORTER_CREDS_MOUNT}/ccd-as-a-pr-importer-password)
fi

[ "_${CREATE_IMPORTER_USER}" = "_true" ] && /scripts/create-importer-user.sh "${IMPORTER_USERNAME}" "${IMPORTER_PASSWORD}" "${IDAM_URI}"

userToken=$(sh ./scripts/idam-authenticate.sh ${IMPORTER_USERNAME} ${IMPORTER_PASSWORD} ${IDAM_URI} ${REDIRECT_URI} ${CLIENT_ID} ${CLIENT_SECRET})

serviceToken=$(curl --silent -X POST ${AUTH_PROVIDER_BASE_URL}/testing-support/lease -d \"{"microservice":"${MICROSERVICE}"}\" -H 'content-type: application/json')

# add ccd role
/scripts/add-ccd-role.sh "${CCD_ROLE}" "PUBLIC" "${userToken}" "${serviceToken}" "${CCD_STORE_BASE_URL}"

for definition in /definitions/[^~]*.xlsx # do not process excel temp files that start with ~
do
  echo "======== PROCESSING FILE $definition ========="

  /scripts/template_ccd_definition.py "$definition" /definition.xlsx "${BULK_SCAN_ORCHESTRATOR_BASE_URL}"

  # upload definition files
  /scripts/import-definition.sh /definition.xlsx "${userToken}" "${serviceToken}" "${CCD_STORE_BASE_URL}"

  echo "======== FINISHED PROCESSING $definition ========="
  echo
done
