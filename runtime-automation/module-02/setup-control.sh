#!/bin/bash

RUNAS="sudo -u rhel"

#Runs bash with commands between '_' as nobody if possible
$RUNAS bash<<_
mkdir /home/rhel/minimal-downstream-with-galaxy/
touch /home/rhel/minimal-downstream-with-galaxy/execution-environment.yml
mkdir /home/rhel/minimal-downstream-with-galaxy/solution-definition/
cat > /home/rhel/minimal-downstream-with-galaxy/solution-definition/execution-environment.yml << EOF
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


loginctl enable-linger rhel

_
#cat <<< $(jq '."[yaml]"."editor.autoIndent" = true' /home/rhel/.local/share/code-server/User/settings.json) > /home/rhel/.local/share/code-server/User/settings.json