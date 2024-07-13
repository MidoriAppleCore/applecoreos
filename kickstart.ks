#version=DEVEL

# Run the Setup Agent on first boot
firstboot --enable

%post
cat << EOF > /etc/install_flatpaks.sh
#!/bin/bash
# Add Flatpak remote if not already added
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install desired Flatpaks
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub org.mozilla.firefox

# Add any additional Flatpak installation commands here
EOF

# Make the script executable
chmod +x /etc/install_flatpaks.sh

# Schedule the script to run on first boot
cat << EOF > /etc/systemd/system/install_flatpaks.service
[Unit]
Description=Install Flatpaks after first boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/etc/install_flatpaks.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# Enable the systemd service
systemctl enable install_flatpaks.service
%end

