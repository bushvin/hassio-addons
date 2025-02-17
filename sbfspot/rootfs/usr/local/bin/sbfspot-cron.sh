#!/command/with-contenv bashio
# shellcheck shell=bash
INTERVAL=${1}

CONFIG_PATH=/data/options.json

UPDATE_INTERVAL=$(bashio::config 'update_interval' 5)
PLANT_NAME=$(bashio::config 'plant_name' '')
PLANT_TZ=$(bashio::config 'plant_timezone' '')
INVERTER_PASSWORD=$(bashio::config 'inverter_password' '0000')

bashio::log.level $(bashio::config 'log_level' 'info')

bashio::log.debug "Interval Tick: ${INTERVAL}"

if test ${INTERVAL} -eq 0 -o ${INTERVAL} -eq ${UPDATE_INTERVAL}; then
    if test $(ps -ef |grep -c [s]bfspot-cron.sh) -gt 0; then
        bashio::log.warning "SBFspot still running. Skipping this run"
        exit 0
    fi
    bashio::log.info "Fetching inverter values"
    . /usr/local/bin/lib-sbfspot.sh
    . /usr/local/bin/lib-mqtt.sh
    SBFSPOT_CONFIGFILE=/etc/sbfspot/SBFspot.cfg
    SBFspot::inverter.get_info
    echo > ${SBFSPOT_CONFIGFILE}
    SBFspot::config.set_filename ${SBFSPOT_CONFIGFILE}
    SBFspot::config.set_value BTAddress $(bashio::config 'inverter_address' '00:00:00:00:00:00')
    if test "$(bashio::config 'local_address' '00:00:00:00:00:00')" != "00:00:00:00:00:00"; then
        SBFspot::config.set_value LocalBTAddress $(bashio::config 'local_address' '00:00:00:00:00:00')
    fi
    SBFspot::config.set_value Plantname ${PLANT_NAME}
    SBFspot::config.set_value Password ${INVERTER_PASSWORD}
    SBFspot::config.set_value Timezone ${PLANT_TZ}
    SBFspot::config.set_value Latitude  $(bashio::config 'plant_latitude' 50.80)
    SBFspot::config.set_value Longitude  $(bashio::config 'plant_longitude' 4.33)
    SBFspot::config.set_value CalculateMissingSpotValues 1
    SBFspot::config.set_value SynchTime 1
    SBFspot::config.set_value SynchTimeLow 60
    SBFspot::config.set_value SynchTimeHigh 3600
    SBFspot::config.set_value Locale en-US
    SBFspot::config.set_value OutputPath /tmp/sbfspot/%Y
    SBFspot::config.set_value CSV_Export 0
    SBFspot::config.set_value MQTT_Publisher /usr/bin/mosquitto_pub
    SBFspot::config.set_value MQTT_Host "$(bashio::config 'mqtt_hostname' 'test.mosquitto.org')"
    SBFspot::config.set_value MQTT_Port "$(bashio::config 'mqtt_port' 1883)"
    SBFspot::config.set_value MQTT_Topic "homeassistant/device/${INVERTER_SERIAL}"
    SBFspot::config.set_value MQTT_ItemFormat "\"{key}\": {value}"
    SBFspot::config.set_value MQTT_ItemDelimiter comma
    SBFspot::config.set_value MQTT_Data "PrgVersion,Plantname,Timestamp,InvTime,SunRise,SunSet,InvSerial,InvName,InvClass,InvType,InvSwVer,InvStatus,InvTemperature,InvGridRelay,ETotal,EToday,PACTot,PDC1,UDC1,IDC1,PDCTot,OperTm,FeedTm,PAC1,PAC2,PAC3,UAC1,UAC2,UAC3,IAC1,IAC2,IAC3,GridFreq,BTSignal,BatTmpVal,BatVol,BatAmp,BatChaStt,InvWakeupTm,InvSleepTm,MeteringWOut,MeteringWIn,MeteringWTot"
    mqtt_topic="homeassistant/device/${INVERTER_SERIAL}"
    SBFspot::config.set_value MQTT_PublisherArgs "-h {host} -p {port} -u ${MQTT_USERNAME} -P '${MQTT_PASSWORD}' -r -t {topic} -m \"{{message}}\""
    SBFspot::config.set_value DateTimeFormat "%Y-%m-%d %H:%M:%S"
    SBFspot::config.set_value DateFormat "%Y-%m-%d"
    SBFspot::config.set_value TimeFormat "%H:%M:%S"
    SBFspot::inverter.get_current_values /etc/sbfspot/SBFspot.cfg
fi
