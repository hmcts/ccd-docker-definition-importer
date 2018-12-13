#!/bin/sh

set -e

USER_EMAIL=$1
PASSWORD=$2

FORENAME=CCD
SURNAME=Importer
USER_GROUP=ccd-import

curl -XPOST -H 'Content-Type: application/json' http://idam-api:8080/testing-support/accounts -d '{
    "email": "'${USER_EMAIL}'",
    "forename": "'${FORENAME}'",
    "surname": "'${SURNAME}'",
    "levelOfAccess": 0,
    "userGroup": {
      "code": "'${USER_GROUP}'"
    },
    "roles": [{ "code": "ccd-import" }],
    "activationDate": "",
    "lastAccess": "",
    "password": "'${PASSWORD}'"
}'

echo "Created user with:"
echo "Username: ${USER_EMAIL}"
echo "Password:${PASSWORD}"
echo "Forename: ${FORENAME}"
echo "Surname: ${SURNAME}"
echo "User group: ${USER_GROUP}"
