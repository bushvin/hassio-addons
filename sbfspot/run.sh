#!/usr/bin/with-contenv bashio

confdir=/etc/sbfspot
conffile=/etc/sbfspot/SBFspot.cfg
CONFIG_PATH=/data/options.json

set -e
export SBFSPOT_INTERVAL=$(bashio::config 'sbfspot_interval' '600')
export SBFSPOT_CONNECTION_TYPE=$(bashio::config 'connection_type' 'bluetooth')
export SBFSPOT_INVERTER_BTADDRESS=$(bashio::config 'inverter_bluetooth_address' '00:00:00:00:00:00')
export SBFSPOT_INVERTER_BTRETRIES=$(bashio::config 'inverter_bluetooth_retries' '10')
export SBFSPOT_INVERTER_PASSWORD=$(bashio::config 'inverter_password' '0000')
export SBFSPOT_INVERTER_IPADDRESS=$(bashio::config 'inverter_ip_address' '0.0.0.0')
export SBFSPOT_LOCAL_BTADDRESS=$(bashio::config 'local_bluetooth_address' '00:00:00:00:00:00')
export SBFSPOT_MIS_ENABLED=$(bashio::config 'multi_inverter_support' 'false')
export SBFSPOT_PLANTNAME=$(bashio::config 'plantname' 'MyPlant')
export SBFSPOT_LATITUDE=$(bashio::config 'inverter_latitude' '50.80')
export SBFSPOT_LONGITUDE=$(bashio::config 'inverter_longitude' '4.33')
export SBFSPOT_CALCULATE_MISSING_SPOTVALUES=$(bashio::config 'inverter_cmsv' 'true')
export SBFSPOT_DATETIMEFORMAT=$(bashio::config 'datetime_format' '%d/%m/%Y %H:%M:%S')
export SBFSPOT_DATEFORMAT=$(bashio::config 'date_format' '%d/%m/%Y')
export SBFSPOT_TIMEFORMAT=$(bashio::config 'time_format' '%H:%M:%S')
export SBFSPOT_DECIMALPOINT=$(bashio::config 'field_delimiter' ',')
export SBFSPOT_SYNCTIME=$(bashio::config 'synctime' 'weekly')
export SBFSPOT_SYNCTIME_LOW=$(bashio::config 'synctime_low' '60')
export SBFSPOT_SYNCTIME_HIGH=$(bashio::config 'synctime_high' '3600')
export SBFSPOT_SUNRSOFFSET=$(bashio::config 'sunRSOffset' '900')
export SBFSPOT_LOCALE=$(bashio::config 'locale' 'en-US')
export SBFSPOT_TIMEZONE=$(bashio::config 'timezone' 'Europe/Brussels')
export SBFSPOT_CSV_EXPORT='false'
export SBFSPOT_SQLITE_EXPORT='false'
export SBFSPOT_MARIADB_EXPORT='false'
export SBFSPOT_MYSQL_EXPORT='false'
export SBFSPOT_MQTT_EXPORT=$(bashio::config 'mqtt_export' 'false')
export SBFSPOT_MQTT_BIN=$(bashio::config 'mqtt_publisher' '/usr/bin/mosquitto_pub')
export SBFSPOT_MQTT_HOSTNAME=$(bashio::config 'mqtt_hostname' '/usr/bin/mosquitto_pub')
export SBFSPOT_MQTT_PORT=$(bashio::config 'mqtt_port' '1883')
export SBFSPOT_MQTT_TOPIC=$(bashio::config 'mqtt_topic' 'sbfspot_{serial}')
export SBFSPOT_MQTT_FORMAT=$(bashio::config 'mqtt_format' 'json')
export SBFSPOT_MQTT_ARGUMENTS=$(bashio::config 'mqtt_arguments' '')
export SBFSPOT_MQTT_DATA=$(bashio::config 'mqtt_data' 'Timestamp,SunRise,SunSet,InvSerial,InvName,InvTime,InvStatus,InvTemperature,InvGridRelay,EToday,ETotal,PACTot,UDC,IDC,PDC')
export SBFSPOT_MQTT_USER=$(bashio::config 'mqtt_user' '')
export SBFSPOT_MQTT_PASSWORD=$(bashio::config 'mqtt_password' '')

export SBFSPOT_BIN_ARGS="-d0 -v2"
export SBFSPOT_MQTT_BIN_ARGS="-h {host} -p {port}"

setConfigValue() {
    local key=$1; shift
    local value=$1; shift
    echo "${key}=${value}" >> ${conffile}
}
echo > $conffile
if [ "${SBFSPOT_CONNECTION_TYPE}" = "bluetooth" ]; then
    setConfigValue BTAddress "${SBFSPOT_INVERTER_BTADDRESS}"
    setConfigValue BTConnectRetries "${SBFSPOT_INVERTER_BTRETRIES}"
    [ "${SBFSPOT_LOCAL_BTADDRESS}" != "00:00:00:00:00:00" ] && setConfigValue LocalBTAddress "${SBFSPOT_LOCAL_BTADDRESS}"
fi

setConfigValue Password "${SBFSPOT_INVERTER_PASSWORD}"
[ "${SBFSPOT_MIS_ENABLED}" = "true" ] && setConfigValue MIS_Enabled 1
[ "${SBFSPOT_MIS_ENABLED}" = "false" ] && setConfigValue MIS_Enabled 0

setConfigValue Plantname "${SBFSPOT_PLANTNAME}"
setConfigValue Latitude "${SBFSPOT_LATITUDE}"
setConfigValue Longitude "${SBFSPOT_LONGITUDE}"
[ "${SBFSPOT_CALCULATE_MISSING_SPOTVALUES}" = "true" ] && setConfigValue CalculateMissingSpotValues 1
[ "${SBFSPOT_CALCULATE_MISSING_SPOTVALUES}" = "false" ] && setConfigValue CalculateMissingSpotValues 0
setConfigValue DateTimeFormat "${SBFSPOT_DATETIMEFORMAT}"
setConfigValue DateFormat "${SBFSPOT_DATEFORMAT}"
setConfigValue TimeFormat "${SBFSPOT_TIMEFORMAT}"
[ "${SBFSPOT_DECIMALPOINT}" = "," ] && setConfigValue DecimalPoint comma
[ "${SBFSPOT_DECIMALPOINT}" = "." ] && setConfigValue DecimalPoint point
if [ "${SBFSPOT_SYNCTIME}" = "disabled" ]; then
    setConfigValue SynchTime 0
elif [ "${SBFSPOT_SYNCTIME}" = "weekly" ]; then
    setConfigValue SynchTime 7
elif [ "${SBFSPOT_SYNCTIME}" = "monthly" ]; then
    setConfigValue SynchTime 30
else
    setConfigValue SynchTime 1
fi
setConfigValue SynchTimeLow "${SBFSPOT_SYNCTIME_LOW}"
setConfigValue SynchTimeHigh "${SBFSPOT_SYNCTIME_HIGH}"
setConfigValue SunRSOffset "${SBFSPOT_SUNRSOFFSET}"
setConfigValue Locale "${SBFSPOT_LOCALE}"
setConfigValue Timezone "${SBFSPOT_TIMEZONE}"
[ "${SBFSPOT_SQLITE_EXPORT}" = "true" ] && setConfigValue CSV_Export 1
[ "${SBFSPOT_SQLITE_EXPORT}" = "false" ] && setConfigValue CSV_Export 0


if [ "${SBFSPOT_MQTT_EXPORT}" = "true" ]; then
    [ -n "${SBFSPOT_MQTT_USER}" ] && SBFSPOT_MQTT_BIN_ARGS="${SBFSPOT_MQTT_BIN_ARGS} -u \"${SBFSPOT_MQTT_USER}\""
    [ -n "${SBFSPOT_MQTT_PASSWORD}" ] && SBFSPOT_MQTT_BIN_ARGS="${SBFSPOT_MQTT_BIN_ARGS} -P \"${SBFSPOT_MQTT_PASSWORD}\""
    setConfigValue MQTT_Publisher "${SBFSPOT_MQTT_BIN}"
    setConfigValue MQTT_Host "${SBFSPOT_MQTT_HOSTNAME}"
    setConfigValue MQTT_Port "${SBFSPOT_MQTT_PORT}"
    setConfigValue MQTT_Topic "${SBFSPOT_MQTT_TOPIC}"
    if [ "${SBFSPOT_MQTT_FORMAT}" = "json" ]; then
        setConfigValue MQTT_ItemFormat "\"{key}\": {value}"
        setConfigValue MQTT_ItemDelimiter comma
        setConfigValue MQTT_PublisherArgs "${SBFSPOT_MQTT_BIN_ARGS} -t \"{topic}\" -m \"{{message}}\" ${SBFSPOT_MQTT_ARGUMENTS[*]}"
    elif [ "${SBFSPOT_MQTT_FORMAT}" = "text" ]; then
        setConfigValue MQTT_ItemFormat "{key}:{value}"
        setConfigValue MQTT_ItemDelimiter semicolon
        setConfigValue MQTT_PublisherArgs "${SBFSPOT_MQTT_BIN_ARGS} -t \"{topic}\" -m \"{message}\" ${SBFSPOT_MQTT_ARGUMENTS[*]}"
    elif [ "$SBFSPOT_MQTT_FORMAT" = "xml" ]; then
        setConfigValue MQTT_ItemFormat "<item name=\"{key}\" value=\"{value}\" />"
        setConfigValue MQTT_ItemDelimiter none
        setConfigValue MQTT_PublisherArgs "${SBFSPOT_MQTT_BIN_ARGS} -t \"{topic}\" -m \"\<mqtt_message\>{message}\</mqtt_message\>\" ${SBFSPOT_MQTT_ARGUMENTS[*]}"
    fi
    setConfigValue MQTT_Data ${SBFSPOT_MQTT_DATA[*]}
fi

[ "${SBFSPOT_CSV_EXPORT}" = "false" ] && SBFSPOT_BIN_ARGS="${SBFSPOT_BIN_ARGS} -nocsv"
if [ "${SBFSPOT_SQLITE_EXPORT}" = "false" ] && [ "${SBFSPOT_MARIADB_EXPORT}" = "false" ] && [ "${SBFSPOT_MYSQL_EXPORT}" = "false" ]; then
    SBFSPOT_BIN_ARGS="${SBFSPOT_BIN_ARGS} -nosql"
fi
[ "${SBFSPOT_MQTT_EXPORT}" = "true" ] && SBFSPOT_BIN_ARGS="${SBFSPOT_BIN_ARGS} -mqtt"

cat "${conffile}"

while true; do
    echo "Start: $(date)"
    echo "Arguments: ${SBFSPOT_BIN_ARGS}"

    # printf "Start: %s" $(date)
    # printf "Arguments: %s" ${SBFSPOT_BIN_ARGS}
    # timeout --foreground 180 /usr/local/bin/SBFspot_nosql ${SBFSPOT_BIN_ARGS}
    echo "End: $(date)"
    echo "Waiting for ${SBFSPOT_INTERVAL} seconds..."
    # printf "End: %s" $(date)
    # printf "Waiting for %d seconds..." ${SBFSPOT_INTERVAL}
    sleep ${SBFSPOT_INTERVAL}
done