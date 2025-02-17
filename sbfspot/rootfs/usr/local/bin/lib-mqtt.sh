#!/command/with-contenv bashio
# shellcheck shell=bash

declare MQTT_HOSTNAME
declare MQTT_PORT
declare MQTT_USERNAME
declare MQTT_PASSWORD
declare MQTT_PUB_ARGS

MQTT_HOSTNAME=$(bashio::config 'mqtt_hostname' 'test.mosquitto.org')
MQTT_PORT=$(bashio::config 'mqtt_port' 1883)
MQTT_USERNAME=$(bashio::config 'mqtt_username' '')
MQTT_PASSWORD=$(bashio::config 'mqtt_password' '')
MQTT_PUB_ARGS=()

# ------------------------------------------------------------------------------
# Get the dirname of this library
# ------------------------------------------------------------------------------
function MQTT::lib.dirname() {
    bashio::log.trace "${FUNCNAME[0]}"

    echo $( dirname -- "${BASH_SOURCE[0]}" )
}

# ------------------------------------------------------------------------------
# Remove all mqtt publisher arguments
# ------------------------------------------------------------------------------
function MQTT::publish.reset() {
    bashio::log.trace "${FUNCNAME[0]}"

    MQTT_PUB_ARGS=()
    MQTT::publish::arg "-h" "${MQTT_HOSTNAME}" "-p" "${MQTT_PORT}" "-q" "2"
    if test -n "${MQTT_USERNAME}" -a -n "${MQTT_PASSWORD}"; then
        MQTT::publish::arg "-u" "${MQTT_USERNAME}" "-P" "${MQTT_PASSWORD}"
    fi
}

# ------------------------------------------------------------------------------
# Add arguments for MQTT publisher
#
# Arguments:
#   $@  Arguments to be used when executing MQTT publisher
# ------------------------------------------------------------------------------
function MQTT::publish::arg() {
    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    for arg in "$@"; do
        MQTT_PUB_ARGS+=(${arg})
    done
}

# ------------------------------------------------------------------------------
# Execute MQTT publisher
# ------------------------------------------------------------------------------
function MQTT::publish.exec() {
    bashio::log.trace "${FUNCNAME[0]}"

    bashio::log.debug "${FUNCNAME[0]} mosquitto_pub arguments: ${MQTT_PUB_ARGS[@]@Q}"
    eval /usr/bin/mosquitto_pub ${MQTT_PUB_ARGS[@]@Q}
    RC=$?
    if test $RC -gt 0; then
        bashio::log.error "An error ocurred running mosquitto_pub: RC ${RC}"
    fi
}

# ------------------------------------------------------------------------------
# Set MQTT device availability
#
# Arguments:
#   $1  set desired availability: online|offline
# ------------------------------------------------------------------------------
function MQTT::device.set_availability() {
    local state=$1

    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    if test "${state}" != "online" -a "${state}" != "offline"; then
        bashio::exit.nok "${FUNCNAME[0]}: invalid avilability selection: ${state}. should be one of: online, offline"
    fi

    local topic="homeassistant/device/${INVERTER_SERIAL}/avalability"
    local payload_file=$(mktemp)
    echo "{\"state\": \"${state}\"}" | jq > "${payload_file}"
    MQTT::publish.reset
    MQTT::publish::arg "-r" "-f" "${payload_file}" "-t" "${topic}"
    MQTT::publish.exec
}

# ------------------------------------------------------------------------------
# Create MQTT device
# ------------------------------------------------------------------------------
function MQTT::device.create() {
    local payload_file=${1:-/etc/sbfspot}/discovery.json

    bashio::log.trace "${FUNCNAME[0]}"

    local topic="homeassistant/device/${INVERTER_SERIAL}/config"
    yq -o=json <(cat $(MQTT::lib.dirname)/discovery.yaml.template | envsubst) > "${payload_file}"
    MQTT::publish.reset
    MQTT::publish::arg "-r" "-f" "${payload_file}" "-t" "${topic}"
    MQTT::publish.exec
}

# ------------------------------------------------------------------------------
# Remove MQTT device
# ------------------------------------------------------------------------------
function MQTT::device.delete() {
    local payload_file=${1:-/etc/sbfspot}/remove.json

    bashio::log.trace "${FUNCNAME[0]}"

    local topic="homeassistant/device/${INVERTER_SERIAL}/config"
    yq -o=json <(cat $(MQTT::lib.dirname)/remove.yaml.template | envsubst) > "${payload_file}"
    MQTT::publish.reset
    MQTT::publish::arg "-r" "-f" "${payload_file}" "-t" "${topic}"
    MQTT::publish.exec
}
