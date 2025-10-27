RUNAS="sudo -u rhel"

#Runs bash with commands between '_' as nobody if possible
$RUNAS bash<<_

rm /home/rhel/minimal-downstream-with-hub-certs/files/ansible.cfg

cat <<EOF >> /home/rhel/minimal-downstream-with-hub-certs/files/ansible.cfg
[galaxy]
server_list = validated_repo,rh_certified_repo

[galaxy_server.validated_repo]
url=https://control-${GUID}.${DOMAIN}/api/galaxy/content/validated/

[galaxy_server.rh_certified_repo]
url=https://control-${GUID}.${DOMAIN}/api/galaxy/content/rh-certified/

EOF

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
_