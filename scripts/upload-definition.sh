#!/bin/sh
set -e

chmod +x /scripts/*.sh

[ "_${CCD_DEF_URLS}" = "_" ] && echo "No definitions to load from CCD_DEF_URLS. Script terminated." && exit 0

mkdir /definitions && cd /definitions

defs=$(echo "$CCD_DEF_URLS" | tr "," "\n")
for def in $defs
do
    echo "Getting \"$def\" ..."
    wget -nd "$def" || (echo "Failed to download \"${def}\". Script terminated." && exit 21)
    echo "done"
done
[ -z "$(ls -A /definitions)" ] && echo "No definitions found to download. Script terminated." && exit 22

if [ ${VERBOSE} = "true" ]; then
  export CURL_OPTS="--fail --verbose"
else
  export CURL_OPTS="--fail --silent --show-error"
fi

if [ "_${IMPORTER_CREDS_MOUNT}" != "_" ]; then
  echo "Getting credentials from vault"
  IMPORTER_USERNAME=$(cat ${IMPORTER_CREDS_MOUNT}/ccd-as-a-pr-importer-username)
  IMPORTER_PASSWORD=$(cat ${IMPORTER_CREDS_MOUNT}/ccd-as-a-pr-importer-password)
fi

[ ${CREATE_IMPORTER_USER} = "true" ] && /scripts/create-importer-user.sh "${IMPORTER_USERNAME}" "${IMPORTER_PASSWORD}" "${IDAM_URI}"

echo "Getting user_token from idam"
userToken=$(/scripts/idam-authenticate.sh ${IMPORTER_USERNAME} ${IMPORTER_PASSWORD} ${IDAM_URI} ${REDIRECT_URI} ${CLIENT_ID} ${CLIENT_SECRET})

echo "Getting service_token from s2s"
serviceToken=$(curl --fail --silent --show-error -X POST ${AUTH_PROVIDER_BASE_URL}/testing-support/lease -d "{\"microservice\":\"${MICROSERVICE}\"}" -H 'content-type: application/json')

# add ccd role
echo "Adding ccd roles"
/scripts/add-ccd-role.sh "${USER_ROLES}" "PUBLIC" "${userToken}" "${serviceToken}" "${CCD_STORE_BASE_URL}"

echo "Loading ccd definitions"
for definition in /definitions/[^~]*.xlsx # do not process excel temp files that start with ~
do
  echo "======== PROCESSING FILE $definition ========="

  /scripts/template_ccd_definition.sh "$definition" /definition.xlsx "${MICROSERVICE_BASE_URL}"

  echo "Uploading definition file"
  /scripts/import-definition.sh /definition.xlsx "${userToken}" "${serviceToken}" "${CCD_STORE_BASE_URL}"

  echo "======== FINISHED PROCESSING $definition ========="
  echo
done
