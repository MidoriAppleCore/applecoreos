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
rpm-ostree install git
rpm-ostree install neovim
rpm-ostree install lxde-common
rpm-ostree install lightdm
rpm-ostree install conman

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable lightdm

# enable conman autostart
echo '@wicd-gtk' >> ~/.config/lxsession/LXDE/autostart

