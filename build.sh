
#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

rpm-ostree install -y tmux podman podman-compose docker curl wget git neovim \
               lxde-common lxterminal lightdm conman virt-manager distrobox \
               flatpak
rpm-ostree override remove firefox firefox-langpacks

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Install Firefox via Flatpak
flatpak install -y flathub org.mozilla.firefox

systemctl enable podman.socket
systemctl enable lightdm
systemctl enable flatpak-system-helper

### Add user 'midori' with no password and add to necessary groups
# Create the user with no password
useradd -m -G wheel,docker -s /bin/bash midori
passwd -d midori
# Ensure user has access to necessary groups
usermod -aG podman midori

### Set LXDE default configurations
# Copy the wallpaper to the appropriate directory
mkdir -p /usr/share/backgrounds
cp /tmp/wallpaper.jpg /usr/share/backgrounds/default_wallpaper.jpg
# Create the default LXDE configuration directory if it doesn't exist
mkdir -p /etc/xdg/lxsession/LXDE
# Set the default wallpaper
cat <<EOF > /etc/xdg/pcmanfm/LXDE/desktop-items-0.conf
[*]
wallpaper_mode=zoom
wallpaper_common=1
wallpaper=/usr/share/backgrounds/default_wallpaper.jpg
EOF

