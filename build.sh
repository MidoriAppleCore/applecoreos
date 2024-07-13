
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

### Configure autostart for Firefox installation
mkdir -p /etc/skel/.config/autostart
cat <<EOF > /etc/skel/.config/autostart/install_firefox.desktop
[Desktop Entry]
Type=Application
Name=Install Firefox
Exec=lxterminal -e /etc/install_firefox.sh
X-GNOME-Autostart-enabled=true
EOF

### Cleanup

# Remove unnecessary packages
rpm-ostree cleanup -m

# Remove temporary files and caches
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*
