#!/bin/bash
set -euxo pipefail

sudo loginctl enable-linger $USER
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/example.service <<EOF
[Unit]
Description=Example Service

[Service]
Type=oneshot
ExecStart=/usr/bin/ruby -e 'STDOUT.puts :out; STDERR.puts :err'
EOF

cat > ~/.config/systemd/user/example.timer <<EOF
[Unit]
Description=Example Timer

[Timer]
OnCalendar=*-*-* *:55
Persistent=true

[Install]
WantedBy=default.target
EOF

systemctl --user enable example.timer --now

systemctl --user status example.service || true
systemctl --user status example.timer || true
systemctl --user list-timers
# sudo adduser $USER systemd-journal
journalctl --user-unit example.service --no-pager
journalctl --user-unit example.timer --no-pager
