#!/bin/bash
#TODO: Support python virtual environments for now global

# This current directory.
: "${WORKDIR:=$(dirname "${BASH_SOURCE[0]}")}"
: "${ROOT_DIR:=${WORKDIR}/..}"
: "${PYTHON_REQUIREMENTS_FILE:="${ROOT_DIR}/requirements.txt"}"

source "${ROOT_DIR}/scripts/common/init.sh"

testing_init() {
    # Check your environment 
    SYSTEM=$(sudo uname)

    if [[ "${SYSTEM}" == "Linux" ]]; then
        DISTRO=$(sudo lsb_release -i)
        if [[ ${DISTRO} == *"Ubuntu"* ]] || [[ ${DISTRO} == *"Debian"* ]] ;then
            log "Your running Debian based Linux."
        else
            #log "Your running Debian based linux.\n You might need to install 'sudo apt-get install build-essential python-dev\n."
            fatal_error "Your not running Debian based Linux."
        fi
    else
        fatal_error "Repository needs Linux system"
    fi
    log "Checking Developer Tools"
    # Check if root
    # Since we need to make sure paths are okay we need to run as normal user he will use ansible
    [[ "$(whoami)" == "root" ]] && fatal_error "Please run as a normal user not root"
    # System requirements
    test_package python3
    test_package pip3
    test_file "${PYTHON_REQUIREMENTS_FILE}"
}

header '################ Setting Up Developer Machine ################'
testing_init

## Install 
## By default we upgrade all packges to latest. if we need to pin packages use the python_requirements
log "This script install python packages defined in '${PYTHON_REQUIREMENTS_FILE}' "
echo "Since we only support global packages installation for now we need root password."
echo "You will be asked for your password."
sudo -H pip install --no-cache-dir  --upgrade --requirement "${PYTHON_REQUIREMENTS_FILE}"


#Touch vpass
echo "Touching vpass"
if [[ -w "$ROOT_DIR" ]]
then
   touch "$ROOT_DIR/.vpass"
else
  sudo touch "$ROOT_DIR/.vpass"
fi
exit 0
