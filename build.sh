
#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages
rpm-ostree install -y tmux podman podman-compose curl wget git neovim \
               lxde-common lxterminal NetworkManager virt-manager distrobox \
               flatpak obconf xarchiver feh htop xpdf xclip w3m\ lightdm \
               lxinput lxrandr lxsession-edit lxsession lxappearance 


#remove default firefox since it might force us to update the base system more often than we want to because of exploits etc
rpm-ostree override remove firefox firefox-langpacks

# Enable necessary services
systemctl enable podman.socket
systemctl enable flatpak-system-helper
systemctl enable lightdm

### Set LXDE default configurations
mkdir -p /usr/share/backgrounds
cp /tmp/wallpaper.jpg /usr/share/backgrounds/default_wallpaper.jpg

mkdir -p /etc/xdg/lxsession/LXDE
cat <<EOF > /etc/xdg/pcmanfm/LXDE/pcmanfm.conf
[*]
[config]
bm_open_method=0
su_cmd=xdg-su -c '%s'

[desktop]
wallpaper_mode=crop
wallpaper=/usr/share/backgrounds/default_wallpaper.jpg
desktop_bg=#000000
desktop_fg=#ffffff
desktop_shadow=#000000

[ui]
always_show_tabs=0
hide_close_btn=0
win_width=640
win_height=480
view_mode=icon
show_hidden=0
sort=name;ascending;
EOF

### Cleanup

# Remove unnecessary packages
rpm-ostree cleanup -m

# Remove temporary files and caches
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*
