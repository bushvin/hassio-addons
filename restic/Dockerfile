ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data for add-on
COPY run.sh /

RUN chmod a+x /run.sh

RUN apk add --no-cache restic mysql-client postgresql-client jq

CMD [ "/run.sh" ]
