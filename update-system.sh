#!/bin/bash

# Authenticate sudo session
sudo -v

# Update Flatpak packages and clean up
echo "[INFO] Updating Flatpak packages..."
flatpak update -y
flatpak uninstall --unused -y

# Update system packages and clean up
sudo -v
echo "[INFO] Updating system packages..."
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y

# Update individual applications
sudo -v
echo "[INFO] Updating rclone..."
sudo rclone selfupdate
echo "[INFO] Updating npm..."
sudo npm install -g npm@latest
echo "[INFO] Updating npm packages..."
sudo npm update -g
echo "[INFO] Updating bun..."
bun upgrade
echo "[INFO] Updating pip..."
pip install --upgrade pip

# Update firmware
sudo -v
echo "[INFO] Updating firmware..."
sudo fwupdmgr refresh --force
sudo fwupdmgr update -y