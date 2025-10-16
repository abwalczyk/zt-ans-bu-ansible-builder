#!/bin/bash
set -e


# Enable standard RHEL repos if available
sudo dnf config-manager --set-enabled rhel-9-baseos-rpms rhel-9-appstream-rpms || true

# Install EPEL if Satellite not available
if ! sudo dnf repolist | grep -q epel; then
  sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm || true
fi

# Allow passwordless sudo
echo "%rhel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/rhel_sudoers
chmod 440 /etc/sudoers.d/rhel_sudoers

# Install Certbot
sudo dnf install -y certbot jq
