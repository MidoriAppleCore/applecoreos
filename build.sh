#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Install necessary packages
dnf install -y \
               ignition \

#systemctl enable podman.socket

# Enable the Ignition service for first boot
systemctl enable ignition-firstboot.service

### Cleanup

# Remove unnecessary packages and clean caches
dnf clean all
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*

echo "Setup completed successfully!"
