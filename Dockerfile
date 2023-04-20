FROM alpine:3.10.3

RUN apk add --no-cache curl jq zip unzip

## Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.2.1/wait /wait

COPY scripts /scripts
RUN ["chmod", "+x", "/wait"]

RUN chmod +x /scripts/*.sh

CMD "/wait" && "/scripts/upload-definition.sh"
