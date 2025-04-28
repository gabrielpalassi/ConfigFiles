#!/bin/bash

# Update DNF configurations
echo "Updating DNF configurations..."
sudo tee /etc/dnf/dnf.conf > /dev/null <<EOF
[main]
max_parallel_downloads=10
defaultyes=True
EOF

# Uninstall unwanted packages
echo "Removing unwanted packages..."
sudo dnf remove -y \
  libreoffice* \
  evince \
  gnome-boxes \
  gnome-contacts \
  mediawriter \
  gnome-tour \
  gnome-extensions \
  gnome-characters \
  rhythmbox \
  gnome-logs \
  malcontent* \
  gnome-connections \
  gnome-abrt \
  totem \
  eog \
  loupe \
  snapshot \
  firefox \
  gnome-system-monitor \
  gnome-maps
sudo dnf autoremove -y
sudo dnf clean all

# Set up RPM Fusion repositories
echo "Setting up RPM Fusion repositories..."
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf update -y @core
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Install adw-gtk3 theme
echo "Installing adw-gtk3 theme..."
sudo dnf install -y adw-gtk3-theme
flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Install common packages
echo "Installing common packages..."
sudo -v ; curl https://rclone.org/install.sh | sudo bash
flatpak install -y flathub \
  net.nokyan.Resources \
  page.tesk.Refine \
  com.mattjakeman.ExtensionManager \
  org.gnome.Snapshot \
  org.gnome.Loupe \
  org.gnome.Decibels \
  org.gnome.Showtime \
  org.mozilla.firefox \
  org.gnome.Geary \
  com.rtosta.zapzap \
  com.visualstudio.code \
  org.onlyoffice.desktopeditors \
  org.gimp.GIMP \
  de.haeckerfelix.Fragments \
  com.discordapp.Discord \
  com.mojang.Minecraft

# GPU-specific configurations
echo "Configuring GPU drivers..."
echo "Please select your GPU type:"
echo "1) Intel"
echo "2) AMD"
echo "3) NVIDIA"
read -rp "Enter the number corresponding to your GPU: " gpu_choice

case $gpu_choice in
  1)
    echo "You selected Intel. Installing Intel VA driver..."
    sudo dnf install -y libva-intel-driver
    ;;
  2)
    echo "You selected AMD. Installing AMD VA and VDPAU drivers..."
    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    ;;
  3)
    echo "You selected NVIDIA. Installing NVIDIA drivers..."
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda libva-nvidia-driver
    sudo dnf mark user akmod-nvidia -y
    echo "Please wait for the kmod to build and reboot your system."
    echo "If using Secure Boot, follow instructions to sign the NVIDIA kmod:"
    echo "https://rpmfusion.org/Howto/NVIDIA"
    echo "https://rpmfusion.org/Howto/Secure%20Boot"
    ;;
  *)
    echo "Invalid choice. Skipping GPU driver installation."
    ;;
esac

echo "Setup complete!"
