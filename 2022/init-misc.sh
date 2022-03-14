#!/bin/bash
set -euxo pipefail
trap "sudo etckeeper vcs gc" EXIT

# /usr/share/dict/american-english
sudo apt-get install -y wamerican

# more packages
sudo apt-get install -y ripgrep
sudo apt-get install -y x11-apps
#sudo apt install -y x11-xserver-utils
#sudo apt install -y x11-utils

# snap
#sudo snap install code --classic
#sudo snap install gimp
#sudo snap install firefox
#sudo snap install node-red
#sudo snap install audacity
#sudo snap install inkscape
#sudo snap install gnome-calculator
#sudo snap install snap-store

# rsz
if ! grep -q rsz ~/.bashrc; then
    cat >> ~/.bashrc <<'EOF'

rsz () if [[ -t 0 ]]; then local escape r c prompt=$(printf '\e7\e[r\e[999;999H\e[6n\e8'); IFS='[;' read -sd R -p "$prompt" escape r c; stty cols $c rows $r; fi
rsz
EOF
fi
