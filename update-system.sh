#!/bin/bash

# Update system packages and clean up
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y

# Update Flatpak packages and clean up
flatpak update -y
flatpak uninstall --unused -y

# Update individual applications
sudo rclone selfupdate
sudo npm install -g npm@latest
sudo npm update -g
bun upgrade
pip install --upgrade pip