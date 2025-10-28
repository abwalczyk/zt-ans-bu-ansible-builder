#!/bin/bash
set -e

# Ensure rhel user exists
id rhel >/dev/null 2>&1 || useradd -m rhel

# Run commands as rhel
# Run commands as rhel
sudo -u rhel bash <<'EOF_RHEL'
source /etc/profile.d/domain_guid.sh

rm /home/rhel/minimal-downstream-with-hub-certs/solution-definition/execution-environment.yml
cat > /home/rhel/minimal-downstream-with-hub-certs/solution-definition/execution-environment.yml << EOF
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
    - ARG ANSIBLE_GALAXY_SERVER_RH_CERTIFIED_REPO_TOKEN
  prepend_base:
    - COPY _build/configs/cert.pem /etc/pki/ca-trust/source/anchors/cert.pem
    - RUN update-ca-trust
EOF

EOF_RHEL