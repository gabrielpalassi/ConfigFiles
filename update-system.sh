#!/bin/bash

# Update system packages and clean up
echo "[Info] Updating system packages..."
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y

# Update Flatpak packages and clean up
echo "[Info] Updating Flatpak packages..."
flatpak update -y
flatpak uninstall --unused -y

# Update individual applications
echo "[Info] Updating rclone..."
sudo rclone selfupdate
echo "[Info] Updating npm..."
sudo npm install -g npm@latest
echo "[Info] Updating npm packages..."
sudo npm update -g
echo "[Info] Updating bun..."
bun upgrade
echo "[Info] Updating pip..."
pip install --upgrade pip