
#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
rpm-ostree install tmux
rpm-ostree install podman
rpm-ostree install podman-compose
rpm-ostree install docker
rpm-ostree install curl wget
rpm-ostree install git
rpm-ostree install neovim
rpm-ostree install lxde-common
rpm-ostree install lxterminal
rpm-ostree install lightdm
rpm-ostree install conman
rpm-ostree install virt-manager
rpm-ostree install distrobox
rpm-ostree remove firefox*

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable lightdm

### Enable Flatpak and install applications via Flatpak

# Enable Flatpak support
rpm-ostree install flatpak

# Add the Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Firefox via Flatpak
flatpak install -y flathub org.mozilla.firefox

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

