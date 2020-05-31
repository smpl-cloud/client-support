#!/usr/bin/env bash
#  PURPOSE: A client runs this script to assign base permissions to SMPL Cloud
#           Support users.
# -----------------------------------------------------------------------------
#  PREREQS: a) Client must have permissions to assign roles to users.
#           b) Client must have gcloud sdk installed
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:     ./client-add-smpl-support.sh
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2020/05/23
# -----------------------------------------------------------------------------
set -x

# Pre-game check
if [[ "${BASH_VERSINFO:-0}" -lt 4 ]]; then
    echo "This script requires GNU Bash v4 to support arrays; please upgrade."
    exit 1
fi

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
domaiName='smpl.sh'
myOrgID=$(gcloud organizations list --format='value(ID)')

# Data
declare smplUsers=("thomas@${domaiName}" "taylorsmith@${domaiName}")

# REF: https://cloud.google.com/iam/docs/understanding-roles
declare gcpRoles=('viewer' 'billing.user' 'resourcemanager.projectCreator' \
    'compute.instanceAdmin.v1' 'compute.networkAdmin' 'container.admin' \
    'storage.admin' 'dns.admin' 'iam.serviceAccountKeyAdmin' \
    'iam.serviceAccountTokenCreator' 'iam.serviceAccountUser')

# REF: https://cloud.google.com/sdk/gcloud/reference/services/list
declare projAPIs=('cloudresourcemanager' 'cloudbilling' 'iam' 'compute' \
    'container' 'containerregistry' 'dns' 'storage-component' 'cloudtrace')


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Add GCP Roles for all SMPL Support Personnel
###---
pMsg "Adding roles for these users..."
for adminRole in "${gcpRoles[@]}"; do
    for user in "${smplUsers[@]}"; do
        gcloud organizations add-iam-policy-binding "$myOrgID" \
            --member="user:$user" \
            --role="roles/${adminRole}"
    done
done


###---
### Enable the APIs
### Any action taken by Terraform requires requisite APIs are enabled.
###---
set +x
printf '\n\n%s\n' "Enabling required APIs..."
for adminAPI in "${projAPIs[@]}"; do
    gcloud services enable "${adminAPI}.googleapis.com"
    pMsg "  * $adminAPI"
done


###---
### REQ
###---


###---
### fin~
###---
exit 0
