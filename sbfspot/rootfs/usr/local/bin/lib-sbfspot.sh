#!/command/with-contenv bashio
# shellcheck shell=bash
declare SBFSPOT_CONFIGFILE
declare SBFSPOT_ARGS
declare INVERTER_DEVICE_NAME
declare INVERTER_DEVICE_TYPE
declare INVERTER_SERIAL

SBFSPOT_CONFIGFILE=/etc/sbfspot/SBFspot.cfg
SBFSPOT_ARGS=()


# ------------------------------------------------------------------------------
# Remove all SBFspot arguments
# ------------------------------------------------------------------------------
function SBFspot::query.reset() {
    bashio::log.trace "${FUNCNAME[0]}"

    local log_level=$(bashio::config 'log_level' 'info')
    SBFSPOT_ARGS=()
    case "${log_level}" in
        "trace")
            SBFSPOT_ARGS=("-v2" "-d2")
            ;;
        "debug")
            SBFSPOT_ARGS=("-v2" "-d0")
            ;;
        "off")
            SBFSPOT_ARGS=("-q")
            ;;
        *)
            SBFSPOT_ARGS=("-v0" "-d0")
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Add arguments for SBFspot
#
# Arguments:
#   $@  Arguments to be used when calling SBFspot
# ------------------------------------------------------------------------------
function SBFspot::query.arg() {
    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    for arg in "$@"; do
        SBFSPOT_ARGS+=(${arg})
    done
}

# ------------------------------------------------------------------------------
# Execute SBFspot query
# ------------------------------------------------------------------------------
function SBFspot::query.exec() {
    bashio::log.trace "${FUNCNAME[0]}"

    bashio::log.debug "${FUNCNAME[0]} SBFspot arguments: ${SBFSPOT_ARGS[@]@Q}"
    eval /usr/local/bin/SBFspot_nosql ${SBFSPOT_ARGS[@]@Q}
    RC=$?
    if test $RC -gt 0; then
        bashio::log.error "An error ocurred running SBFspot_nosql: RC ${RC}"
    fi
}

# ------------------------------------------------------------------------------
# Get inverter values
#
# Arguments:
#  $1  SBFspot config file location
# ------------------------------------------------------------------------------
function SBFspot::inverter.get_current_values() {
    local config_file=${1}
    local sbfspot_args=()

    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    SBFspot::query.reset
    SBFspot::query.arg "-ad0" "-am0" "-ae0" "-mqtt" "-nosql" "-nocsv" "-cfg${config_file}"
    SBFspot::query.exec
}

# ------------------------------------------------------------------------------
# Get inverter information
#
# Arguments:
#  $1  SBFspot config file location (optional)
#  $2  target directory for the CSV files (optional)
# ------------------------------------------------------------------------------
function SBFspot::inverter.get_info() {
    if test $# -gt 0; then
        local config_file=${1}
    else
        local config_file=""
    fi
    if test $# -gt 1; then
        local target_dir=${2}
    else
        local target_dir=""
    fi

    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    if test -f /data/inverter.conf; then
        bashio::log.debug "${FUNCNAME[0]}: found /data/inverter.conf, importing"
        . /data/inverter.conf
    else
        INVERTER_DEVICE_NAME=""
        INVERTER_DEVICE_TYPE=""
        INVERTER_SERIAL=""
    fi
    if test -n "${INVERTER_DEVICE_NAME}" -a -n "${INVERTER_DEVICE_TYPE}" -a -n "${INVERTER_SERIAL}"; then
        bashio::log.trace "${FUNCNAME[0]}: INVERTER_DEVICE_NAME: ${INVERTER_DEVICE_NAME}"
        bashio::log.trace "${FUNCNAME[0]}: INVERTER_DEVICE_TYPE: ${INVERTER_DEVICE_TYPE}"
        bashio::log.trace "${FUNCNAME[0]}: INVERTER_SERIAL: ${INVERTER_SERIAL}"
        return
    fi

    if test -z "${config_file}"; then
        bashio::exit.nok "${FUNCNAME[0]}: config_file is not defined"
    fi
    if test -z "${target_dir}"; then
        bashio::exit.nok "${FUNCNAME[0]}: target_dir is not defined"
    fi
    SBFspot::query.reset
    SBFspot::query.arg "-ad0" "-am0" "-ae0" "-nosql" "-finq" "-cfg${config_file}"
    SBFspot::query.exec

    if test $(find "${target_dir}" -type f -maxdepth 1 -regex '^.*-Spot-.*\.csv$' | wc -l) -ne 1; then
        bashio::exit.nok '${FUNCNAME[0]}: Spot file was not found.'
    fi

    csvfile="$(find "${target_dir}" -type f -maxdepth 1 -regex '^.*-Spot-.*\.csv$')"

    bashio::log.debug "$(cat ${csvfile})"
    local IFS=";"
    local values=($(tail -n1 "${csvfile}"))
    export INVERTER_DEVICE_NAME=${values[1]}
    export INVERTER_DEVICE_TYPE=${values[2]}
    export INVERTER_SERIAL=${values[3]}
    EXIT_ERROR=0
    if test -z "${INVERTER_DEVICE_NAME}"; then
        bashio::log.error "${FUNCNAME[0]}: Could not determine device name"
        EXIT_ERROR=1
    fi
    if test -z "${INVERTER_DEVICE_TYPE}"; then
        bashio::log.error "${FUNCNAME[0]}: Could not determine device type"
        EXIT_ERROR=1
    fi
    if test -z "${INVERTER_SERIAL}"; then
        bashio::log.error "${FUNCNAME[0]}: Could not determine device serial number"
        EXIT_ERROR=1
    fi
    if test ${EXIT_ERROR} -gt 0; then
        bashio::exit.nok "${FUNCNAME[0]}: Error(s) were raised"
    fi
    echo "#!/usr/bin/env bash" > /data/inverter.conf
    echo "export INVERTER_DEVICE_NAME=\"${INVERTER_DEVICE_NAME}\"" >> /data/inverter.conf
    echo "export INVERTER_DEVICE_TYPE=\"${INVERTER_DEVICE_TYPE}\"" >> /data/inverter.conf
    echo "export INVERTER_SERIAL=\"${INVERTER_SERIAL}\"" >> /data/inverter.conf
}

# ------------------------------------------------------------------------------
# Set the location for the config, used by SBFspot::config.set_value()
#
# Arguments:
#  $1  SBFspot config file location
# ------------------------------------------------------------------------------
SBFspot::config.set_filename() {
    SBFSPOT_CONFIGFILE="$1"

    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    if test ! -e "$(dirname ${SBFSPOT_CONFIGFILE})"; then
        mkdir -p "$(dirname ${SBFSPOT_CONFIGFILE})"
    fi
    touch "${SBFSPOT_CONFIGFILE}"
}

# ------------------------------------------------------------------------------
# Set a config parameter
#
# Arguments:
#  $1  SBFspot config key name
#  $2  SBFspot config value
# ------------------------------------------------------------------------------
SBFspot::config.set_value() {
    local key=$1
    local value=$2

    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    # TODO: make this better
    echo "${key}=${value}" >> ${SBFSPOT_CONFIGFILE}
}
