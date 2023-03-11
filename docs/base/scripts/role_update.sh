#!/bin/bash

# This current directory.
: "${WORKDIR:=$(dirname "${BASH_SOURCE[0]}")}"
: "${ROOT_DIR:=${WORKDIR}/..}"
: "${EXTERNAL_ROLE_DIR:="${ROOT_DIR}/roles/external"}"
: "${EXTERNAL_COLLECTION_DIR:="${ROOT_DIR}/collections/external"}"
: "${ROLES_REQUIREMENTS_FILE:="${ROOT_DIR}/requirements.yml"}"

source "${ROOT_DIR}/scripts/common/init.sh"

header "################ Downloading Roles ################"
# Check ansible-galaxy
test_package ansible-galaxy
# Check roles req file
test_file "${ROLES_REQUIREMENTS_FILE}"
# Install roles
if [[ ! -d "${EXTERNAL_ROLE_DIR}" ]]; then
    ansible-galaxy install -r "${ROLES_REQUIREMENTS_FILE}" --force --no-deps -p "${EXTERNAL_ROLE_DIR}"
else
    log "Roles are present already. Remove them and try again."
fi
# Install collections
if [[ ! -d "${EXTERNAL_COLLECTION_DIR}" ]]; then
    ansible-galaxy collection install -r "${ROLES_REQUIREMENTS_FILE}" --force --no-deps -p "${EXTERNAL_COLLECTION_DIR}"
else
    log "Collections are present already. Remove them and try again."
fi
exit 0
