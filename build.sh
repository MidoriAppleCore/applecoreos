
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

### Copy the kickstart file
mkdir -p /iso
cp /tmp/kickstart.ks /iso/

### Modify the bootloader configuration to use the kickstart file
# Assuming using isolinux/syslinux
#sed -i 's/append initrd=initrd.img/append initrd=initrd.img ks=cdrom:\/kickstart.ks/' /iso/isolinux/isolinux.cfg

#If using GRUB
sed -i 's/linuxefi \/vmlinuz.*/& ks=cdrom:\/kickstart.ks/' /iso/EFI/BOOT/grub.cfg

### Cleanup

# Remove unnecessary packages
rpm-ostree cleanup -m

# Remove temporary files and caches
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*

