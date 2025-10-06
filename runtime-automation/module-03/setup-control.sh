#!/bin/bash

RUNAS="sudo -u rhel"

#Runs bash with commands between '_' as nobody if possible
$RUNAS bash<<_
mkdir /home/rhel/minimal-downstream-with-hub/
mkdir /home/rhel/minimal-downstream-with-hub/files/

cat > /home/rhel/minimal-downstream-with-hub/execution-environment.yml << EOF
---
version: 3

images:
  base_image:
    name: registry.redhat.io/ansible-automation-platform-24/ee-minimal-rhel8:latest

dependencies:
  galaxy:
    collections:
    - ansible.netcommon

options:
  package_manager_path: /usr/bin/microdnf
EOF

mkdir /home/rhel/minimal-downstream-with-hub/solution-definition/
cat > /home/rhel/minimal-downstream-with-hub/solution-definition/execution-environment.yml << EOF
---
version: 3

images:
  base_image:
    name: registry.redhat.io/ansible-automation-platform-24/ee-minimal-rhel8:latest

dependencies:
  galaxy:
    collections:
    - ansible.netcommon

options:
  package_manager_path: /usr/bin/microdnf

additional_build_files:
  - src: files
    dest: configs

additional_build_steps:
  prepend_galaxy:
    - COPY _build/configs/ansible.cfg /etc/ansible/ansible.cfg

build_arg_defaults:
  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--ignore-certs'

EOF

token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST https://privatehub-01/api/galaxy/v3/auth/token/ -k | jq .token`

cat <<EOF >> /home/rhel/minimal-downstream-with-hub/files/ansible.cfg
[galaxy]
server_list = validated_repo,rh_certified_repo

[galaxy_server.validated_repo]
url=https://privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/api/galaxy/content/validated/
token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST https://privatehub-01/api/galaxy/v3/auth/token/ -k | jq .token | xargs`

[galaxy_server.rh_certified_repo]
url=https://privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/api/galaxy/content/rh-certified/
token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST https://privatehub-01/api/galaxy/v3/auth/token/ -k | jq .token | xargs`

EOF
_

#curl https://letsencrypt.org/certs/lets-encrypt-r3.pem --output /etc/pki/ca-trust/source/anchors/cert.pem
#update-ca-trust
