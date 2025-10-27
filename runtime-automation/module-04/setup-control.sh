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