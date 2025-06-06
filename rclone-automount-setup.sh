#!/bin/bash

# Create systemd user and iCloud Drive directories
mkdir -p ~/.config/systemd/user/
mkdir -p ~/iCloud Drive

# Create rclone-icloud.service
cat > ~/.config/systemd/user/rclone-icloud.service <<EOF
[Unit]
Description=Mount iCloudDrive with rclone
After=network-online.target
Wants=network-online.target
OnFailure=rclone-icloud-failure-notify.service

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount iCloudDrive: "%h/iCloud Drive" --vfs-cache-mode full --vfs-cache-poll-interval 30s --dir-cache-time 30s

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
ExecStartPre=/bin/bash -c 'while ! busctl --user --no-pager list | grep -q org.freedesktop.Notifications; do sleep 1; done; sleep 1'
ExecStart=%h/.config/systemd/user/rclone-icloud-failure-notify.sh

[Install]
WantedBy=default.target
EOF

# Create rclone-icloud-failure-notify.sh script
cat > ~/.config/systemd/user/rclone-icloud-failure-notify.sh <<EOF
#!/bin/bash

ACTION=$(dunstify --appname="iCloud Drive" \
                  --urgency=critical \
                  --icon=dialog-error \
                  --action="restart,Restart Service" \
                  --action="config,Open Rclone Config" \
                  "Mount Failed" \
                  "Restart the service or open rclone config to troubleshoot")

case "$ACTION" in
  "restart")
    systemctl --user restart rclone-icloud.service
    ;;
  "config")
    ptyxis -- bash -c 'echo -ne "\033]0;Rclone Config\007"; rclone config'
    ;;
esac
EOF

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable and start the rclone-icloud service
systemctl --user enable rclone-icloud.service
systemctl --user start rclone-icloud.service

echo "iCloud Drive mount service installed and started."

