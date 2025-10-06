#!/bin/bash

RUNAS="sudo -u rhel"

#Runs bash with commands between '_' as nobody if possible
$RUNAS bash<<_
mkdir /home/rhel/minimal-downstream-with-hub-certs/
mkdir /home/rhel/minimal-downstream-with-hub-certs/files/

cat > /home/rhel/minimal-downstream-with-hub-certs/execution-environment.yml << EOF
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

mkdir /home/rhel/minimal-downstream-with-hub-certs/solution-definition/
cat > /home/rhel/minimal-downstream-with-hub-certs/solution-definition/execution-environment.yml << EOF
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
  prepend_base:
    - COPY _build/configs/cert.pem /etc/pki/ca-trust/source/anchors/cert.pem
    - RUN update-ca-trust

EOF

token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST https://privatehub-01/api/galaxy/v3/auth/token/ -k | jq .token`

cat <<EOF >> /home/rhel/minimal-downstream-with-hub-certs/files/ansible.cfg
[galaxy]
server_list = validated_repo,rh_certified_repo

[galaxy_server.validated_repo]
url=https://privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/api/galaxy/content/validated/
token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST https://privatehub-01/api/galaxy/v3/auth/token/ -k | jq .token | xargs`

[galaxy_server.rh_certified_repo]
url=https://privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/api/galaxy/content/rh-certified/
token=`curl -s -u admin:ansible123! -H "Content-Type: application/json" -X POST https://privatehub-01/api/galaxy/v3/auth/token/ -k | jq .token | xargs`

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
sudo certbot certonly --no-bootstrap --standalone -d privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io --email ansible-network@redhat.com --noninteractive --agree-tos
sudo cp /etc/letsencrypt/live/privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/privkey.pem /etc/pulp/certs/pulp_webserver.key
sudo cp /etc/letsencrypt/live/privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/fullchain.pem /etc/pulp/certs/pulp_webserver.crt
sudo restorecon -v /etc/pulp/certs/pulp_webserver.crt
sudo restorecon -v /etc/pulp/certs/pulp_webserver.key
sudo systemctl start pulpcore-api
sudo systemctl start nginx