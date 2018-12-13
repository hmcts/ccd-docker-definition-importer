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

[ "_${CREATE_IMPORTER_USER}" = "_true" ] && /scripts/create-importer-user.sh ${IMPORTER_USERNAME} ${IMPORTER_PASSWORD}

userToken=$(sh ./scripts/idam-authenticate.sh ${IMPORTER_USERNAME} ${IMPORTER_PASSWORD} ${IDAM_URI} ${REDIRECT_URI} ${CLIENT_ID} ${CLIENT_SECRET})

# add ccd role
/scripts/add-ccd-role.sh "${CCD_ROLE}" "PUBLIC" "${userToken}" "${API_GATEWAY_BASE_URL}"

for definition in /definitions/C*.xlsx # use C to not process excel temp files that start with ~
do
  echo "======== PROCESSING FILE $definition ========="

  /scripts/template_ccd_definition.py "$definition" /definition.xlsx "${BULK_SCAN_ORCHESTRATOR_BASE_URL}"

  # upload definition files
  /scripts/import-definition.sh /definition.xlsx "${userToken}" "${AUTH_PROVIDER_BASE_URL}" "${MICROSERVICE}" "${CCD_STORE_BASE_URL}"

  echo "======== FINISHED PROCESSING $definition ========="
  echo
done
