#!/bin/sh 
set -e

chmod +x /scripts/*.sh


[ "_${CCD_DEF_URLS}${CCD_DEF_FILENAME}" = "_" ] && echo "No definitions to load from CCD_DEF_URLS or CCD_DEF_FILENAME. Script terminated." && exit 0

mkdir /definitions && cd /definitions

if [ "_${CCD_DEF_URLS}" != "_" ]; then
  defs=$(echo "$CCD_DEF_URLS" | tr "," "\n")
  for def in $defs
  do
      echo "Getting \"$def\" ..."
      if [ "_${GITHUB_CREDS_MOUNT}" != "_" ] && [ -f ${GITHUB_CREDS_MOUNT}/hmcts-github-apikey ]; then
        echo "Getting github credentials from vault"
        ACCESS_TOKEN=$(cat ${GITHUB_CREDS_MOUNT}/hmcts-github-apikey)
        headers="Authorization: token ${ACCESS_TOKEN}"
      fi
      wget -nd --header="$headers" "$def" || (echo "Failed to download \"${def}\". Script terminated." && exit 21)
      echo "done"
  done
elif [ "_${CCD_DEF_FILENAME}" != "_" ]; then
  cp /${CCD_DEF_FILENAME} /definitions/${CCD_DEF_FILENAME}
fi

[ -z "$(ls -A /definitions)" ] && echo "No definitions found to download. Script terminated." && exit 22

if [ ${VERBOSE} = "true" ]; then
  export CURL_OPTS="--fail --verbose"
else
  export CURL_OPTS="--fail --silent --show-error"
fi

if [ "_${IMPORTER_SECRETS_MOUNT}" != "_" ]; then
  echo "Getting secrets from flex mounted volumes"
  IMPORTER_USERNAME=$(cat ${IMPORTER_SECRETS_MOUNT}/ccd-importer-autotest-email)
  IMPORTER_PASSWORD=$(cat ${IMPORTER_SECRETS_MOUNT}/ccd-importer-autotest-password)
  CLIENT_SECRET=$(cat ${IMPORTER_SECRETS_MOUNT}/ccd-api-gateway-oauth2-client-secret)
fi

[ ${CREATE_IMPORTER_USER} = "true" ] && /scripts/create-importer-user.sh "${IMPORTER_USERNAME}" "${IMPORTER_PASSWORD}" "${IDAM_URI}"

echo "Getting user_token from idam"
userToken=$(/scripts/idam-authenticate.sh ${IMPORTER_USERNAME} ${IMPORTER_PASSWORD} ${IDAM_URI} ${REDIRECT_URI} ${CLIENT_ID} ${CLIENT_SECRET})


_healthy="false"

if [ "$AUTH_PROVIDER_BASE_URL" != "" ]; then
 
  HEALTH_URL="${AUTH_PROVIDER_BASE_URL}/health"
  echo "==========  Getting service_token from s2s  ==============================="
  for i in $(seq 0 30)
  do
    sleep 10
    echo $i
    wget -O - "$HEALTH_URL" >/dev/null
    [ "$?" == "0" ] && _healthy="true" && break
  done
   
  if [ "$_healthy" != "true" ]; then
    echo "Error: application does not seem to be running, check the application logs to see why" 
    exit 2
  else 
     serviceToken=$(curl --fail --silent --show-error -X POST ${AUTH_PROVIDER_BASE_URL}/testing-support/lease -d "{\"microservice\":\"${MICROSERVICE}\"}" -H 'content-type: application/json')
  fi
fi


# add ccd role
echo "Adding ccd roles"
/scripts/add-ccd-role.sh "${USER_ROLES}" "PUBLIC" "${userToken}" "${serviceToken}" "${CCD_STORE_BASE_URL}"

echo "Loading ccd definitions"
for definition in /definitions/[^~]*.xlsx # do not process excel temp files that start with ~
do
  echo "======== PROCESSING FILE $definition ========="

  rm -f /definition.xlsx
  /scripts/template_ccd_definition.sh "$definition" /definition.xlsx "${MICROSERVICE_BASE_URL}"

  echo "Uploading definition file"
  /scripts/import-definition.sh /definition.xlsx "${userToken}" "${serviceToken}" "${CCD_STORE_BASE_URL}"

  echo "======== FINISHED PROCESSING $definition ========="
  echo
done
