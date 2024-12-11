## https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
## based on https://github.com/habuild/hassio-addons haos-sbfspot
ARG BUILD_FROM
FROM $BUILD_FROM AS builder-base

# Execute during the build of the image
ARG TEMPIO_VERSION BUILD_ARCH
#ARG BUILD_ARCH
#ARG SBFSPOT_VERSION=3.9.11
#ARG TEMPIO_VERSION=2024.11.2

RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install requirements
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
# RUN apk update && apk add --no-cache \
#     bluez=5.76-r0 \
#     bluez-dev=5.76-r0 \
#     boost-dev=1.82.0-r5 \
#     curl-dev=8.8.0-r0 \
#     git=2.45.2-r0 \
#     g++=13.2.1_git20240309-r0 \
#     make=4.4.1-r2 \
#     mariadb-dev=10.11.8-r0\
#     mosquitto-clients=2.0.18-r0 \
#     tzdata=2024a-r1

# download and build SBFspot
WORKDIR /tmp
RUN git clone https://github.com/sbfspot/SBFspot.git .
# RUN git checkout tags/v3.9.11 -b version-3.9.11

WORKDIR /tmp/SBFspot
RUN sed -i s-\#ifdef\ linux-\#ifdef\ linux\\n\#include\ \<sys\/select.h\>- Ethernet.h
RUN sed -i s-\#ifdef\ linux-\#ifdef\ linux\\n\#include\ \<sys\/select.h\>- bluetooth.h
#RUN sed -i s/mariadbclient/mariadb/ makefile

RUN make nosql
#RUN make sqlite
#RUN make mysql
#RUN make mariadb

# WORKDIR /tmp/SBFspotUploadDaemon
# RUN make nosql && make sqlite && make mysql && make mariadb

    # && sed -i s/mariadbclient/mariadb/ ./SBFspot/makefile \
    # && make -C ./SBFspot mariadb \
    # && sed -i s/mariadbclient/mariadb/ ./SBFspotUploadDaemon/makefile \
    # && make -C ./SBFspotUploadDaemon mariadb


# runtinme container
FROM $BUILD_FROM

# ARG user=sbfspot
# ARG group=sbfspot
# ARG uid=5000
# ARG gid=5000
# ENV SBFSPOT_INTERVAL 300

ARG TEMPIO_VERSION BUILD_ARCH SBFSPOT_USER SBFSPOT_GROUP SBFSPOT_UID SBFSPOT_GID
# ARG SBFSPOT_USER SBFSPOT_GROUP SBFSPOT_UID SBFSPOT_GID

RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]


RUN apk update && apk add --no-cache \
    bluez \
    nano \
    bluez-libs \
    libstdc++ \
    mariadb-common \
    mariadb-connector-c \
    ncurses-libs \
    libcurl \
    mosquitto-clients

# RUN apk update && apk add --no-cache \
#     bluez=5.76-r0 \
#     nano=8.0-r0 \
#     bluez-libs=5.76-r0 \
#     libstdc++=13.2.1_git20240309-r0 \
#     mariadb-common=10.11.8-r0 \
#     mariadb-connector-c=3.3.10-r0 \
#     ncurses-libs=6.4_p20240420-r0 \
#     libcurl=8.7.1-r0 \
#     mosquitto-clients=2.0.18-r0

# Copy data for add-on
WORKDIR /usr/local/bin

COPY --from=builder-base /tmp/SBFspot/nosql/bin/SBFspot /usr/local/bin/SBFspot_nosql
# COPY --from=builder-base /tmp/SBFspot/mariadb/bin/SBFspot /usr/bin/sbfspot/SBFspot
# COPY --from=builder-base /tmp/SBFspotUploadDaemon/mariadb/bin/SBFspotUploadDaemon /usr/bin/sbfspot/SBFspotUploadDaemon
COPY --from=builder-base /tmp/SBFspot/date_time_zonespec.csv /usr/local/bin/date_time_zonespec.csv
COPY --from=builder-base /tmp/SBFspot/TagList* /usr/local/bin/

# COPY --from=builder-base /tmp/SBFspot/mariadb/bin/SBFspot /usr/bin/sbfspot/SBFspot
# COPY --from=builder-base /tmp/SBFspotUploadDaemon/mariadb/bin/SBFspotUploadDaemon /usr/bin/sbfspot/SBFspotUploadDaemon
# COPY --from=builder-base /tmp/SBFspot/date_time_zonespec.csv /usr/bin/sbfspot/date_time_zonespec.csv
# COPY --from=builder-base /tmp/SBFspot/TagList* /usr/bin/sbfspot/



#RUN cp /tmp/SBFspot/mariadb/bin/SBFspot /usr/bin/sbfspot \
# && cp /tmp/SBFspotUploadDaemon/mariadb/bin/SBFspotUploadDaemon /usr/bin/sbfspot \
# && cp /tmp/SBFspot/date_time_zonespec.csv /usr/bin/sbfspot \
# && cp /tmp/SBFspot/TagList* /usr/bin/sbfspot

RUN chmod a+x /usr/local/bin/SBFspot_nosql

# # --- install cron ---
# # set shell
# RUN echo 'SHELL=/bin/bash' > /etc/crontabs/root
# # update sensors after restart
# RUN echo '@reboot sleep 30 && /usr/bin/sbfspot/SBFspot -v -ad0 -am0 -mqtt -finq > /dev/stdout' >> /etc/crontabs/root
# # daily data SBFspot
# RUN echo '*/5 6-22 * * *    /usr/bin/sbfspot/SBFspot -v -ad1 -am0 -ae0 -mqtt > /dev/stdout' >> /etc/crontabs/root
# # monthly data SBFspot archive upload at 5:55am now with -mqtt call
# RUN echo '55 05 * * *       /usr/bin/sbfspot/SBFspot -v -sp0 -ad14 -am1 -ae1 -mqtt -finq > /dev/stdout' >> /etc/crontabs/root
# # start SBFspotUpload 1 min after boot
# RUN echo '@reboot sleep 60 && /usr/bin/sbfspot/SBFspotUploadDaemon -c /usr/bin/sbfspot/SBFspotUpload.cfg > /dev/stdout' >> /etc/crontabs/root
# #  Log SBFspotUpload to HA logging window  defunct now in version 3.9.6+ sbfspot, using it for the timed message
# RUN echo '*/5 6-22 * * * /usr/bin/sbfspot/taillog.sh' >> /etc/crontabs/root

# Labels
LABEL \
    io.hass.name="SBFspot" \
    io.hass.description="Home Assistant addon for Bluetooth SBFspot, is an open source project to get actual and archive data out of an SMA® inverter over Bluetooth or Ethernet (Speedwire®)" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="bushvin <https://community.home-assistant.io/u/bushvin>" \
    org.label-schema.description="Home Assistant addon for Bluetooth SBFspot, is an open source project to get actual and archive data out of an SMA® inverter over Bluetooth or Ethernet (Speedwire®)" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="sbfspot" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/bushvin/hassio-addons/tree/main/sbfspot" \
    org.label-schema.usage="https://github.com/bushvin/hassio-addons/tree/main/sbfspot/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/bushvin/hassio-addons" \
    org.label-schema.vendor="bushvin"

COPY ./run.sh /

# ARG SBFSPOT_USER SBFSPOT_GROUP SBFSPOT_UID SBFSPOT_GID

RUN addgroup -g ${SBFSPOT_GID} -S ${SBFSPOT_GROUP}
RUN adduser -S -D -G ${SBFSPOT_GROUP} -H -u ${SBFSPOT_UID} ${SBFSPOT_USER}
RUN mkdir /etc/sbfspot
RUN chown ${SBFSPOT_USER}:${SBFSPOT_GROUP} /etc/sbfspot
RUN chmod u+x /run.sh
RUN chown ${SBFSPOT_USER}:${SBFSPOT_GROUP} /run.sh

USER ${SBFSPOT_USER}

ENTRYPOINT ["/run.sh"]
#Launch nginx with debug options. not working yet
#CMD [ "nginx","-g","daemon off;error_log /dev/stdout debug;" ]