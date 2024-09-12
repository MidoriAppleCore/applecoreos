#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

rpm-ostree install -y tmux podman podman-compose curl wget git \
               NetworkManager virt-manager distrobox \
               flatpak  \
               pop-icon-theme sshfs pipewire \
               terminus* konsole pavucontrol oneko vulkan-tools \
               swtpm swtpm-tools kubernetes kubernetes-kubeadm kubernetes-client \
               plasma-desktop plasma-workspace-wayland plasma-nm dolphin kscreen 


#remove default firefox since it might force us to update the base system more often than we want to because of exploits etc
rpm-ostree override remove firefox firefox-langpacks

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

rpm-ostree install -y code # or code-insiders

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
rpm-ostree install minikube-latest.x86_64.rpm
rm minikube-latest.x86_64.rpm

# Enable necessary services
systemctl enable podman.socket
systemctl enable flatpak-system-helper

### Cleanup

# Remove unnecessary packages
rpm-ostree cleanup -m

# Remove temporary files and caches
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*
