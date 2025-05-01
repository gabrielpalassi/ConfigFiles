#!/bin/bash

# Update system packages and clean up
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y

# Update rclone
sudo rclone self-update

# Update Flatpak packages and clean up
flatpak update -y
flatpak uninstall --unused -y
