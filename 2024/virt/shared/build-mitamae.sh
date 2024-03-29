#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")"

# https://github.com/itamae-kitchen/mitamae-build
arch=$(uname -m)
os=$(uname -s | tr '[:upper:]' '[:lower:]')
mitamae="/mnt/shared/mitamae-$arch-$os"
if [[ -x "$mitamae" ]]; then
    exit
fi

sudo apt-get install -y ruby
sudo apt-get install -y build-essential
sudo apt-get install -y autoconf
sudo apt-get install -y libtool

if [[ ! -d "$HOME/mitamae" ]]; then
    git clone https://github.com/itamae-kitchen/mitamae "$HOME/mitamae"
fi
cd "$HOME/mitamae"
rake compile

# https://github.com/itamae-kitchen/mitamae-build
arch=$(uname -m)
os=$(uname -s | tr '[:upper:]' '[:lower:]')
cp -a "$HOME/mitamae/mruby/build/host/bin/mitamae" "$mitamae"
exit
