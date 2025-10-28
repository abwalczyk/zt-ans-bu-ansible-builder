#!/bin/bash
set -e

# Ensure rhel user exists
id rhel >/dev/null 2>&1 || useradd -m rhel

# Run commands as rhel
# Run commands as rhel
sudo -u rhel bash <<'EOF_RHEL'
source /etc/profile.d/domain_guid.sh
mkdir /home/rhel/minimal-downstream-with-hub-certs/
mkdir /home/rhel/minimal-downstream-with-hub-certs/files/

cat > /home/rhel/minimal-downstream-with-hub-certs/execution-environment.yml << EOF
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

mkdir /home/rhel/minimal-downstream-with-hub-certs/solution-definition/
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
  prepend_base:
    - COPY _build/configs/cert.pem /etc/pki/ca-trust/source/anchors/cert.pem
    - RUN update-ca-trust
EOF

# --- Get token
token=$(curl -s -u admin:ansible123! -H "Content-Type: application/json" \
  -X POST https://control.lab/api/galaxy/v3/auth/token/ -k | jq -r .token)

cat <<EOF >> /home/rhel/minimal-downstream-with-hub-certs/files/ansible.cfg
[galaxy]
server_list = validated_repo,rh_certified_repo

[galaxy_server.validated_repo]
url=https://control-${GUID}.${DOMAIN}/api/galaxy/content/validated/
token=${token}

[galaxy_server.rh_certified_repo]
url=https://control-${GUID}.${DOMAIN}/api/galaxy/content/rh-certified/
token=${token}

EOF
curl https://letsencrypt.org/certs/lets-encrypt-r3.pem --output /home/rhel/minimal-downstream-with-hub-certs/files/cert.pem

touch /etc/sudoers.d/rhel_sudoers
echo "%rhel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/rhel_sudoers
cp -a /root/.ssh/* /home/rhel/.ssh/.
chown -R rhel:rhel /home/rhel/.ssh
#dnf config-manager --enable rhui*

sudo systemctl stop pulpcore-api
sudo systemctl stop nginx
sudo systemctl start snapd
sudo certbot certonly --no-bootstrap --standalone -d control-${GUID}.${DOMAIN} --email ansible-network@redhat.com --noninteractive --agree-tos
sudo cp /etc/letsencrypt/live/control-${GUID}.${DOMAIN}/privkey.pem /etc/pulp/certs/pulp_webserver.key
sudo cp /etc/letsencrypt/live/control-${GUID}.${DOMAIN}/fullchain.pem /etc/pulp/certs/pulp_webserver.crt
sudo restorecon -v /etc/pulp/certs/pulp_webserver.crt
sudo restorecon -v /etc/pulp/certs/pulp_webserver.key
sudo systemctl start pulpcore-api
sudo systemctl start nginx

EOF_RHEL
