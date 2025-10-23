#!/bin/bash
set -e

# Ensure rhel user exists
id rhel >/dev/null 2>&1 || useradd -m rhel

# Run commands as rhel
sudo -u rhel bash <<'EOF_RHEL'
mkdir -p /home/rhel/minimal-downstream-with-galaxy/solution-definition/
mkdir /home/rhel/minimal-downstream-with-galaxy/
touch /home/rhel/minimal-downstream-with-galaxy/execution-environment.yml

cat > /home/rhel/minimal-downstream-with-galaxy/solution-definition/execution-environment.yml <<'YAML'
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

YAML
EOF_RHEL

# Enable lingering as root (must be outside the sudo block)
loginctl enable-linger rhel
