#!/bin/bash
set -euo pipefail

if [ "${DEBUG:=false}" == "true" ]; then
    set -x
fi

#DIR=$(dirname "$0")
#: "${SPACE:=""}"
#: "${MANDATORY:?must be set}"
#ROOT_DIR=$(cd "${ROOT_DIR}" &> /dev/null && pwd)

: "${COLOR_END:='\e[0m'}"
: "${COLOR_RED:='\e[0;31m'}" # Red
: "${COLOR_YEL:='\e[0;33m'}" # Yellow
: "${COLOR_GREEN:='\e[0;32m'}" # Green

: "${TIME_FORMAT:=`date "+%d-%m-%Y %H:%M:%S"`}"

header() {
    printf "${COLOR_GREEN}${*}${COLOR_END} %b\n"
    sleep 5
}

log() {
    printf "${COLOR_YEL}${TIME_FORMAT}: LOG: ${*}${COLOR_END} %b\n";
}

fatal_error() {
    printf "${COLOR_RED}${TIME_FORMAT}: ERROR: ${*} ${COLOR_END} %b\n" >&2;
    exit 1
}

test_package() {
    command -v ${1} >/dev/null 2>&1 || fatal_error "Setup Requires ${1} but it's not installed. Please install it and try again."
}

test_file() {
    [[ -e ${1} ]] || fatal_error "Setup Requires ${1} but does not exist or permssion issue. Please check and try again."
}