#!/bin/bash

# Create systemd user directory
mkdir -p ~/.config/systemd/user/

# Create rclone-icloud.service
cat > ~/.config/systemd/user/rclone-icloud.service <<EOF
[Unit]
Description=Mount iCloudDrive with rclone
After=network-online.target
OnFailure=rclone-icloud-failure-notify.service

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount iCloudDrive: "/home/gabrielpalassi/iCloud Drive" --vfs-cache-mode full --vfs-cache-poll-interval 30s --dir-cache-time 30s
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Create rclone-icloud-failure-notify.service
cat > ~/.config/systemd/user/rclone-icloud-failure-notify.service <<EOF
[Unit]
Description=Notify user of rclone iCloud Drive mount failure
After=graphical-session.target

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c 'while ! busctl --user --no-pager list | grep -q org.freedesktop.Notifications; do sleep 1; done'
ExecStart=/usr/bin/notify-send --app-name="iCloud Drive" --urgency=critical --icon=dialog-error "iCloud Drive Mount Failed" "Try restarting the service with 'systemctl --user restart rclone-icloud.service'. If that doesn't work, run 'rclone reconnect'."

[Install]
WantedBy=default.target
EOF

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable and start the rclone-icloud service
systemctl --user enable rclone-icloud.service
systemctl --user start rclone-icloud.service

echo "iCloud Drive mount service installed and started."

