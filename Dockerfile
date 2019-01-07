FROM alpine:3.8

RUN apk add --no-cache curl jq zip unzip

## Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.2.1/wait /wait

COPY scripts /scripts
RUN ["chmod", "+x", "/wait"]

RUN chmod +x /scripts/*.sh
RUN pip3 install -r /scripts/requirements.txt

CMD "/wait" && "/scripts/upload-definition.sh"
