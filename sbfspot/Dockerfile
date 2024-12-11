## https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM SBFSPOT_VERSION
FROM $BUILD_FROM AS builder-base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk update && apk add --no-cache \
    bluez \
    bluez-dev \
    boost-dev \
    curl-dev \
    git \
    g++ \
    make \
    mariadb-dev \
    mosquitto-clients \
    tzdata

WORKDIR /tmp
RUN git clone https://github.com/SBFspot/SBFspot.git .

WORKDIR /tmp/SBFspot
RUN sed -i s-\#ifdef\ linux-\#ifdef\ linux\\n\#include\ \<sys\/select.h\>- Ethernet.h
RUN sed -i s-\#ifdef\ linux-\#ifdef\ linux\\n\#include\ \<sys\/select.h\>- bluetooth.h

RUN make nosql


FROM $BUILD_FROM

ARG BUILD_ARCH SBFSPOT_USER SBFSPOT_GROUP SBFSPOT_UID SBFSPOT_GID

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY run.sh /
RUN chmod a+x /run.sh

COPY --from=builder-base /tmp/SBFspot/nosql/bin/SBFspot /usr/local/bin/SBFspot_nosql
COPY --from=builder-base /tmp/SBFspot/date_time_zonespec.csv /usr/local/bin/date_time_zonespec.csv
COPY --from=builder-base /tmp/SBFspot/TagList* /usr/local/bin/
RUN chmod a+x /usr/local/bin/SBFspot_nosql

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
