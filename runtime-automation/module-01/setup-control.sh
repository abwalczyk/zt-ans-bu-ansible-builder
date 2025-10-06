#!/bin/bash

echo '}' >> /etc/nginx/nginx.conf
systemctl restart nginx

sudo dnf -y install jq

touch /etc/sudoers.d/rhel_sudoers
echo "%rhel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/rhel_sudoers
cp -a /root/.ssh/* /home/rhel/.ssh/.
chown -R rhel:rhel /home/rhel/.ssh
#dnf config-manager --enable rhui*
sudo subscription-manager repos --disable rhel-8-for-x86_64-appstream-rpms

sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf install -y certbot

#sudo systemctl stop pulpcore-api
#sudo systemctl stop nginx
#sudo systemctl start snapd
#sudo certbot certonly --no-bootstrap --standalone -d privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io --email ansible-network@redhat.com --noninteractive --agree-tos
#sudo cp /etc/letsencrypt/live/privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/privkey.pem /etc/pulp/certs/pulp_webserver.key
#sudo cp /etc/letsencrypt/live/privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/fullchain.pem /etc/pulp/certs/pulp_webserver.crt
#sudo restorecon -v /etc/pulp/certs/pulp_webserver.crt
#sudo restorecon -v /etc/pulp/certs/pulp_webserver.key
sudo systemctl start pulpcore-*
#sudo systemctl start nginx

host_ip=`getent ahostsv4 privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io | awk '{print $1}' | head -1`
sudo sed -i -r 's/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/privatehub-01.$INSTRUQT_PARTICIPANT_ID.instruqt.io/ /etc/pulp/settings.py
sudo systemctl restart pulpcore-api
sudo systemctl restart nginx
