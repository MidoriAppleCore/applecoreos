#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages
rpm-ostree install -y tmux podman podman-compose docker curl wget git neovim \
               lxde-common lxterminal lightdm conman virt-manager distrobox \
               flatpak
rpm-ostree override remove firefox firefox-langpacks

# Enable necessary services
systemctl enable podman.socket
systemctl enable lightdm
systemctl enable flatpak-system-helper

### Add user 'midori' with no password and add to necessary groups
useradd -m -G wheel,docker -s /bin/bash midori
passwd -d midori
groupadd -f podman
usermod -aG podman midori

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo -u midori flatpak install -y flathub org.mozilla.firefox

### Set LXDE default configurations
mkdir -p /usr/share/backgrounds
cp /tmp/wallpaper.jpg /usr/share/backgrounds/default_wallpaper.jpg

mkdir -p /etc/xdg/lxsession/LXDE
cat <<EOF > /etc/xdg/pcmanfm/LXDE/desktop-items-0.conf
[*]
wallpaper_mode=zoom
wallpaper_common=1
wallpaper=/usr/share/backgrounds/default_wallpaper.jpg
EOF

cat <<EOF > /etc/xdg/lxsession/LXDE/autostart
@lxpanel --profile LXDE
@pcmanfm --desktop --profile LXDE
EOF

### Cleanup

# Remove unnecessary packages
rpm-ostree cleanup -m

# Remove temporary files and caches
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*
