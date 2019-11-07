#!/bin/bash
set -e

GITHUB_TOKEN=$(az keyvault secret show --vault-name infra-vault-prod --name hmcts-github-apikey -o tsv --query value)

az acr task create \
    --registry hmctspublic \
    --subscription DCD-CNP-PROD \
    --name task-ccd-definition-importer \
    --file acr-build-task.yaml \
    --context https://github.com/hmcts/ccd-docker-definition-importer.git \
    --branch RDM-6151 \
    --git-access-token $GITHUB_TOKEN