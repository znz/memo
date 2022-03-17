#!/bin/bash
set -euxo pipefail
trap "sudo etckeeper vcs gc" EXIT

# Japanese
sudo apt install -y language-pack-ja
sudo localectl set-locale LANG=ja_JP.utf8
sudo apt install -y fonts-noto-cjk-extra

# snap
sudo snap install chromium
mkdir -p ~/.webdrivers
ln -sfn /snap/bin/chromium.chromedriver ~/.webdrivers/chromedriver

# SSH X11Fowarding
# $(limactl show-ssh default) -MS none -X
if ! grep -q XAUTHORITY ~/.bashrc; then
    cat >> ~/.bashrc <<'EOF'

if [ -n "$DISPLAY" ]; then
  export XAUTHORITY=$HOME/.Xauthority
fi
EOF
fi
