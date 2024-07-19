

#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Install packages
rpm-ostree install -y tmux podman podman-compose curl wget git neovim leafpad \
               lxde-common NetworkManager virt-manager distrobox \
               flatpak obconf xarchiver gpicview htop xpdf xclip w3m lightdm \
               lxinput lxrandr lxterminal lxsession-edit lxsession lxappearance \
               pop-icon-theme sshfs gnome-screenshot pipewire alsa-utils \
               terminus* lxpolkit ansible alacritty pavucontrol

#remove default firefox since it might force us to update the base system more often than we want to because of exploits etc
rpm-ostree override remove firefox firefox-langpacks

# Enable necessary services
systemctl enable podman.socket
systemctl enable flatpak-system-helper
systemctl enable lightdm

### Set LXDE default configurations
mkdir -p /usr/share/backgrounds
cp /tmp/wallpaper.jpg /usr/share/backgrounds/default_wallpaper.jpg
# Modify the LightDM GTK greeter configuration to use the new wallpaper

#figure out if we have to do this later!
RUN mkdir -p /etc/lightdm && touch /etc/lightdm/lightdm-gtk-greeter.conf && sed -i 's|^background=.*|background=/usr/share/backgrounds/default_wallpaper.jpg|' /etc/lightdm/lightdm-gtk-greeter.conf || echo 'background=/usr/share/backgrounds/default_wallpaper.jpg' >> /etc/lightdm/lightdm-gtk-greeter.conf

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

mkdir -p /etc/xdg/lxsession/LXDE
cat <<EOF > /etc/xdg/lxsession/LXDE/desktop.conf
[Session]
window_manager=openbox-lxde

[GTK]
sNet/ThemeName=Adwaita
sNet/IconThemeName=Pop
sGtk/FontName=Sans 10
iGtk/ToolbarStyle=3
iGtk/ButtonImages=1
iGtk/MenuImages=1
iGtk/CursorThemeSize=18
iXft/Antialias=1

[Mouse]
AccFactor=20
AccThreshold=10
LeftHanded=0

[Keyboard]
Delay=500
Interval=30
EOF

mkdir -p /etc/xdg/lxpanel/LXDE/panels/
cat <<EOF > /etc/xdg/lxpanel/LXDE/panels/panel
# lxpanel <profile> config file. Manually editing is not recommended.
# Use preference dialog in lxpanel to adjust config when you can.

Global {
  edge=bottom
  align=left
  margin=0
  widthtype=percent
  width=100
  height=38
  transparent=1
  tintcolor=#000000
  alpha=112
  setdocktype=1
  setpartialstrut=1
  autohide=0
  heightwhenhidden=0
  usefontcolor=1
  fontcolor=#ffffff
  background=0
  backgroundfile=/usr/share/lxpanel/images/background.png
  iconsize=28
}
Plugin {
  type=space
  Config {
    Size=2
  }
}
Plugin {
  type=menu
  Config {
    image=/usr/share/icons/Bluecurve/24x24/apps/icon-panel-menu.png
    system {
    }
    separator {
    }
    item {
      image=system-run
      command=run
    }
    separator {
    }
    item {
      image=system-logout
      command=logout
    }
  }
}
Plugin {
  type=launchbar
  Config {
    Button {
      id=pcmanfm.desktop
    }
    Button {
      id=lxterminal.desktop
    }
  }
}
Plugin {
  type=space
  Config {
    Size=4
  }
}
Plugin {
  type=wincmd
  Config {
    Button1=iconify
    Button2=shade
    Toggle=1
  }
}
Plugin {
  type=space
  Config {
    Size=4
  }
}
Plugin {
  type=pager
  Config {
  }
}
Plugin {
  type=space
  Config {
    Size=4
  }
}
Plugin {
  type=taskbar
  expand=1
  Config {
    tooltips=1
    IconsOnly=0
    AcceptSkipPager=1
    ShowIconified=1
    ShowMapped=1
    ShowAllDesks=0
    UseMouseWheel=1
    UseUrgencyHint=1
    FlatButton=-1
    MaxTaskWidth=150
    spacing=1
  }
}
Plugin {
  type=tray
  Config {
  }
}
Plugin {
  type=dclock
  Config {
    ClockFmt=%r
    TooltipFmt=%A %x
    BoldFont=1
    IconOnly=0
    CenterText=0
  }
}
Plugin {
  type=launchbar
  Config {
    Button {
      id=lxde-screenlock.desktop
    }
    Button {
      id=lxde-logout.desktop
    }
  }
}
EOF

### Cleanup

# Remove unnecessary packages
rpm-ostree cleanup -m

# Remove temporary files and caches
rm -rf /var/cache/dnf /var/lib/dnf /tmp/* /var/tmp/*
