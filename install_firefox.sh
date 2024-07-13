
#!/bin/bash

# Install Firefox flatpak
flatpak install -y flathub org.mozilla.firefox

# Remove the autostart entry to prevent running on future logins
rm -f ~/.config/autostart/install_firefox.desktop
