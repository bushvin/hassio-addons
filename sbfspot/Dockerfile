ARG BUILD_FROM
FROM $BUILD_FROM AS builder-base

ARG SBFSPOT_VERSION
ENV SBFSPOT_VERSION="${SBFSPOT_VERSION}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk update && apk add --no-cache \
    bluez \
    bluez-dev \
    boost-dev \
    curl-dev \
    git \
    g++ \
    make \
    mosquitto-clients \
    tar \
    tzdata

WORKDIR /tmp
RUN mkdir /tmp/sbfspot
RUN curl -OLvs https://github.com/SBFspot/SBFspot/archive/refs/tags/V${SBFSPOT_VERSION}.tar.gz
RUN tar zxvf /tmp/V${SBFSPOT_VERSION}.tar.gz --strip-components=1 --directory /tmp/sbfspot

WORKDIR /tmp/sbfspot/SBFspot
RUN sed -i s-\#ifdef\ linux-\#ifdef\ linux\\n\#include\ \<sys\/select.h\>- Ethernet.h
RUN sed -i s-\#ifdef\ linux-\#ifdef\ linux\\n\#include\ \<sys\/select.h\>- bluetooth.h

RUN make nosql


FROM $BUILD_FROM
ARG SBFSPOT_USER SBFSPOT_GROUP SBFSPOT_UID SBFSPOT_GID
ENV SBFSPOT_USER="${SBFSPOT_USER}"
ENV SBFSPOT_GROUP="${SBFSPOT_GROUP}"
ENV SBFSPOT_UID="${SBFSPOT_UID}"
ENV SBFSPOT_GID="${SBFSPOT_GID}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /

COPY --from=builder-base /tmp/sbfspot/SBFspot/nosql/bin/SBFspot /usr/local/bin/SBFspot_nosql
COPY --from=builder-base /tmp/sbfspot/SBFspot/date_time_zonespec.csv /usr/local/bin/date_time_zonespec.csv
COPY --from=builder-base /tmp/sbfspot/SBFspot/TagList* /usr/local/bin/
RUN chmod a+x /usr/local/bin/SBFspot_nosql

RUN apk update && apk add --no-cache \
    bluez \
    bluez-libs \
    coreutils \
    libstdc++ \
    ncurses-libs \
    libcurl \
    mosquitto-clients \
    jq \
    yq \
    gettext-envsubst

RUN addgroup -g ${SBFSPOT_GID} -S ${SBFSPOT_GROUP}
RUN adduser -S -D -G ${SBFSPOT_GROUP} -H -u ${SBFSPOT_UID} ${SBFSPOT_USER}
RUN mkdir /etc/sbfspot
RUN chown ${SBFSPOT_USER}:${SBFSPOT_GROUP} /etc/sbfspot

# USER ${SBFSPOT_USER}

# CMD [ "/run.sh" ]
