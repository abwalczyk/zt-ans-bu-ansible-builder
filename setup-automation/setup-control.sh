#!/bin/bash

echo "%rhel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/rhel_sudoers
chmod 440 /etc/sudoers.d/rhel_sudoers

sudo -u rhel install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo -u rhel install -y certbot