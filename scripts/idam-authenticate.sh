#!/bin/sh

IMPORTER_USERNAME=$1
IMPORTER_PASSWORD=$2
IDAM_URI=$3
REDIRECT_URI=$4
CLIENT_ID=$5
CLIENT_SECRET=$6

curl -XPOST "${IDAM_URI}/o/token" -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=password' -d "password=${IMPORTER_PASSWORD}" -d "username=${IMPORTER_USERNAME}" -d "client_id=${CLIENT_ID}" -d "client_secret=${CLIENT_SECRET}" -d 'scope=openid profile roles'| jq -r .access_token
