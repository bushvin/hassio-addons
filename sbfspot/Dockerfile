## https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH SBFSPOT_USER SBFSPOT_GROUP SBFSPOT_UID SBFSPOT_GID

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY run.sh /
RUN chmod a+x /run.sh

RUN apk update && apk add --no-cache \
    bluez \
    bluez-libs \
    libstdc++ \
    mariadb-common \
    mariadb-connector-c \
    ncurses-libs \
    libcurl \
    mosquitto-clients

RUN addgroup -g ${SBFSPOT_GID} -S ${SBFSPOT_GROUP}
RUN adduser -S -D -G ${SBFSPOT_GROUP} -H -u ${SBFSPOT_UID} ${SBFSPOT_USER}
RUN mkdir /etc/sbfspot
RUN chown ${SBFSPOT_USER}:${SBFSPOT_GROUP} /etc/sbfspot
RUN chown ${SBFSPOT_USER}:${SBFSPOT_GROUP} /run.sh
RUN echo ${BUILD_ARCH} > /etc/sbfspot/test

USER ${SBFSPOT_USER}

CMD [ "/run.sh" ]
