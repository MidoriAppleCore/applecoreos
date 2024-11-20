#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Install necessary packages
dnf install -y tmux podman podman-compose curl wget git \
               NetworkManager virt-manager distrobox \
               flatpak \
               pop-icon-theme sshfs pipewire \
               terminus* konsole pavucontrol oneko vulkan-tools ignition

# Install LXDE desktop environment
sudo dnf groupinstall -y "LXDE Desktop"

# Remove default Firefox (avoiding frequent updates due to exploits)
dnf remove -y firefox firefox-langpacks

# Add Microsoft repository and import GPG key for Visual Studio Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Install Visual Studio Code (or Insiders version if preferred)
dnf install -y code

# Enable necessary services
systemctl enable podman.socket
systemctl enable flatpak-system-helper

# Set up Ignition configuration and service
mkdir -p /boot/ignition
cat << 'EOF' > /boot/ignition/config.ign
{
  "ignition": { "version": "3.3.0" },
  "storage": {
    "files": [
      {
        "path": "/etc/motd",
        "contents": { "source": "data:,Welcome%20to%20your%20custom%20build!" },
        "mode": 420
      }
    ]
  }
}
EOF

# Create and enable Ignition systemd service
cat << 'EOF' > /etc/systemd/system/ignition-firstboot.service
[Unit]
Description=Ignition First Boot Configuration
After=network-online.target
ConditionFirstBoot=true

[Service]
Type=oneshot
ExecStart=/usr/bin/ignition --config-file=/boot/ignition/config.ign

[Install]
WantedBy=multi-user.target
EOF

# Enable the Ignition service for first boot
systemctl enable ignition-firstboot.service

### Cleanup

# Remove unnecessary packages and clean caches
dnf clean all
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*

echo "Setup completed successfully!"
