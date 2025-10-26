#!/bin/bash
set -e

# Ensure rhel user exists
id rhel >/dev/null 2>&1 || useradd -m rhel

# Run commands as rhel
sudo -u rhel bash <<'EOF_RHEL'
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
    name: registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel8:latest

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

token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST control.lab/api/galaxy/v3/auth/token/ -k | jq .token`

cat <<EOF >> /home/rhel/minimal-downstream-with-hub/files/ansible.cfg
[galaxy]
server_list = validated_repo,rh_certified_repo

[galaxy_server.validated_repo]
url=https://control-${GUID}.apps.ocpvdev01.rhdp.net/api/galaxy/content/validated/
token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST control.lab/api/galaxy/v3/auth/token/ -k | jq .token | xargs`

[galaxy_server.rh_certified_repo]
url=https://control-${GUID}.apps.ocpvdev01.rhdp.net/api/galaxy/content/rh-certified/
token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST control.lab/api/galaxy/v3/auth/token/ -k | jq .token | xargs`

EOF
_