#!/bin/bash

# Update system packages and clean up
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y

# Update Flatpak packages and clean up
flatpak update -y
flatpak uninstall --unused -y
flatpak repair

# Update rclone
rclone selfupdate
