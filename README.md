# ccd-docker-definition-importer

Docker image to load definitions into CCD. Definitions are excel files which are retrieved from urls passed to the image comma-separated in an environment variables.

## Building

Any commit or merge into master will automatically trigger an Azure ACR task. This task has been manually
created using `./bin/deploy-acr-task.sh`. The task is defined in `acr-build-task.yaml`. 

Note: the deploy script relys on a GitHub token (https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line) defined in `infra-vault-prod`, secret `hmcts-github-apikey`. The token is for setting up a webhook so Azure will be notified when a merge or commit happens. Make sure you are a repo admin and select token scope of: `admin:repo_hook  Full control of repository hooks`

More info on ACR tasks can be read here: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview

## Configuration

The scripts that load the definitions expect the following environment to be available.

| Parameter                | Description                                                                                                                 | Default                                                                                                                         |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| `CCD_DEF_URLS`           | List of URLs to retrieve the definition xls files.                                  | `nil`       
| `CCD_DEF_FILENAME`       | The base image doesn’t contain any definition files. But services / clients have to build a wrapper image on top of it by baking required definition file at image root level e.g. ccd-definitions.xlsx  | `nil`                                                                                                                             |
| `WAIT_HOSTS`             | Hosts to wait for before loading the definitions                                                                            | `ccd-user-profile-api:4453, ccd-definition-store-api:4451, service-auth-provider-api:8080, ccd-api-gateway:3453, idam-api:8080` |
| `VERBOSE`                | Output extra info                                                                                                           | `false`                                                                                                                         |
| `CREATE_IMPORTER_USER`   | Create importer user. Used only with local version of Idam.                                                                 | `false`                                                                                                                         |
| `IMPORTER_USERNAME`      | Importer user name. The idam user authorised to import.                                                                     | `ccd-importer@server.net`                                                                                                       |
| `IMPORTER_PASSWORD`      | Importer password. The idam password for the user authorised to import                                                      | `Password12`                                                                                                                    |
| `IDAM_URI`               | Base URL to access idam                                                                                                     | `http://idam-api:8080`                                                                                                          |
| `REDIRECT_URI`           | Base URL for idam auth redirect                                                                                             | `http://localhost:3000/receiver`                                                                                                |
| `CLIENT_ID`              | Client Id for idam                                                                                                          | `bsp`                                                                                                                           |
| `CLIENT_SECRET`          | Client secret for idam                                                                                                      | `123456`                                                                                                                        |
| `USER_ROLES`             | CCD User Roles to use with the definitions (comma-separated string)                                                         | `caseworker-bulkscan`                                                                                                           |
| `MICROSERVICE_BASE_URL`  | Base URL for the microservice the definitions are for. This will also be used as replacement value in the definition files. | `http://host.docker.internal:8582`                                                                                              |
| `AUTH_PROVIDER_BASE_URL` | Base URL for the service auth provider to get a token for the definitions import                                            | `http://service-auth-provider-api:8080`                                                                                         |
| `MICROSERVICE`           | Microservice the definitions are for.                                                                                       | `bulk_scan_orchestrator`                                                                                                        |
| `CCD_STORE_BASE_URL`     | Base URL for the CCD store the definitions are loaded in.                                                                   | `http://ccd-definition-store-api:4451`                                                                                          |

**Note**: Use `raw` for github CCD definition files URLs (instead of `blob`). For instance:
```
  - https://github.com/hmcts/chart-ccd/raw/master/data/CCD_Definition_Test_Exception_Record.template.xlsx
  - https://github.com/hmcts/chart-ccd/raw/master/data/CCD_Definition_Test.template.xlsx
```
