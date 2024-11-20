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


dnf install -y \
audit \
basesystem \
bash \
coreutils \
curl \
dhcp-client \
e2fsprogs \
filesystem \
glibc \
hostname \
iproute \
iputils \
kbd \
less \
man-db \
ncurses \
openssh-clients \
openssh-server \
parted \
policycoreutils \
procps-ng \
rootfiles \
selinux-policy-targeted \
setup \
shadow-utils \
sssd-common \
sssd-kcm \
sudo \
systemd \
util-linux \
vim-minimal \
NetworkManager \
dracut-config-rescue \
firewalld \
fwupd \
plymouth \
systemd-resolved \
zram-generator-defaults \
dracut-config-generic \
initial-setup \
initscripts \
ppp \
ModemManager \
NetworkManager-adsl \
NetworkManager-ppp \
NetworkManager-wwan \
lrzsz \
minicom \
efax \
linux-atm \
pptp \
rp-pppoe \
statserial \
wvdial \
hyperv-daemons \
open-vm-tools-desktop \
qemu-guest-agent \
spice-vdagent \
spice-webdavd \
virtualbox-guest-additions \
adwaita-gtk2-theme \
adwaita-icon-theme \
clipit \
firewall-config \
galculator \
gigolo \
gnome-keyring-pam \
gpicview \
initial-setup-gui \
leafpad \
lxappearance \
lxappearance-obconf \
lxde-common \
lxdm \
lxinput \
lxlauncher \
lxmenu-data \
lxpanel \
lxpolkit \
lxrandr \
lxsession \
lxsession-edit \
lxtask \
lxterminal \
network-manager-applet \
nm-connection-editor \
notification-daemon \
obconf \
openbox \
openssh-askpass \
pcmanfm \
perl-File-MimeInfo \
upower \
xarchiver \
xcompmgr \
xdg-user-dirs-gtk \
xpad \
xscreensaver-base \
xscreensaver-extras \
alsa-ucm \
alsa-utils \
libva-intel-media-driver \
pipewire-alsa \
pipewire-gstreamer \
pipewire-pulseaudio \
pipewire-utils \
wireplumber \
cups \
cups-filters \
ghostscript \
bluez-cups \
colord \
cups-browsed \
cups-pk-helper \
gutenprint \
gutenprint-cups \
hplip \
mpage \
nss-mdns \
paps \
samba-client \
system-config-printer-udev \
a2ps \
cups-pdf \
enscript \
foomatic \
foomatic-db-ppds \
pnm2ppa \
ptouch-driver \
splix \
system-config-printer \
abrt-cli \
acl \
amd-ucode-firmware \
at \
attr \
bash-color-prompt \
bash-completion \
bc \
bind-utils \
btrfs-progs \
bzip2 \
cifs-utils \
compsize \
cpio \
crontabs \
cryptsetup \
cyrus-sasl-plain \
dbus \
default-editor \
deltarpm \
dos2unix \
dosfstools \
ed \
ethtool \
exfatprogs \
file \
fpaste \
fprintd-pam \
gnupg2 \
hunspell \
iptstate \
irqbalance \
logrotate \
lsof \
mailcap \
man-pages \
mcelog \
mdadm \
microcode_ctl \
mtr \
net-tools \
nfs-utils \
nmap-ncat \
ntfs-3g \
ntfsprogs \
opensc \
passwdqc \
pciutils \
pinfo \
plocate \
psacct \
quota \
realmd \
rsync \
rsyslog \
smartmontools \
sos \
sssd-proxy \
sudo \
symlinks \
systemd-udev \
tar \
tcpdump \
time \
traceroute \
tree \
unzip \
usbutils \
wget2-wget \
which \
whois \
words \
zip \
chrony  \
glx-utils \
mesa-dri-drivers \
mesa-vulkan-drivers \
plymouth-system-theme \
xorg-x11-drv-amdgpu \
xorg-x11-drv-ati \
xorg-x11-drv-evdev \
xorg-x11-drv-intel \
xorg-x11-drv-libinput \
xorg-x11-drv-nouveau \
xorg-x11-drv-openchrome \
xorg-x11-drv-qxl \
xorg-x11-drv-vmware \
xorg-x11-drv-wacom \
xorg-x11-server-Xorg \
xorg-x11-xauth \
xorg-x11-xinit \
firefox \
pidgin \
sylpheed \
transmission \
abiword \
gnumeric \
osmo


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
