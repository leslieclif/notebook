#!/bin/bash

# This current directory.
: "${WORKDIR:=$(dirname "${BASH_SOURCE[0]}")}"
: "${ROOT_DIR:=${WORKDIR}/..}"
source "${ROOT_DIR}/scripts/common/init.sh"
log "Changing to Root Directory"
WORKDIR=$(cd "${ROOT_DIR}" &> /dev/null && pwd)
: "${EXTERNAL_ROLE_DIR:="${WORKDIR}/roles/external"}"
: "${EXTERNAL_COLLECTION_DIR:="${WORKDIR}/collections/external"}"
: "${ROLES_REQUIREMENTS_FILE:="${WORKDIR}/requirements.yml"}"

header "################ Cleaning External Roles ################"

# Remove existing roles
if [[ -d "${EXTERNAL_ROLE_DIR}" ]]; then
    cd "${EXTERNAL_ROLE_DIR}"
	if [ "$(pwd)" == "${EXTERNAL_ROLE_DIR}" ];then
	  log "Removing current roles in '${EXTERNAL_ROLE_DIR}/*'"
	  rm -rf *
	  cd .. && rmdir external
	else
	  fatal_error "Path error could not change dir to ${EXTERNAL_ROLE_DIR}"
	fi
fi
# Remove existing collections
if [[ -d "${EXTERNAL_COLLECTION_DIR}" ]]; then
    cd "${EXTERNAL_COLLECTION_DIR}"
	if [ "$(pwd)" == "${EXTERNAL_COLLECTION_DIR}" ];then
	  log "Removing current collections in '${EXTERNAL_COLLECTION_DIR}/*'"
	  rm -rf *
	  cd .. && rmdir external
	else
	  fatal_error "Path error could not change dir to ${EXTERNAL_COLLECTION_DIR}"
	fi
fi
exit 0
