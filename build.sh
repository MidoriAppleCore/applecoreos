
#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages
#rpm-ostree install -y tmux podman podman-compose curl wget git neovim leafpad \
#               lxde-common lxterminal NetworkManager virt-manager distrobox \
#               flatpak obconf xarchiver gpicview htop xpdf xclip w3m lightdm \
#               lxinput lxrandr lxsession-edit lxsession lxappearance \
#               pop-icon-theme sshfs
rpm-ostree install -y tmux podman podman-compose curl wget git vim-minimal \
               virt-manager distrobox \
               flatpak htop w3m gdm \
               pop-icon-theme sshfs


#remove default firefox since it might force us to update the base system more often than we want to because of exploits etc
rpm-ostree override remove firefox firefox-langpacks

# Enable necessary services
systemctl enable podman.socket
systemctl enable flatpak-system-helper
systemctl enable gdm

### Cleanup

# Remove unnecessary packages
rpm-ostree cleanup -m

# Remove temporary files and caches
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*
