#!/bin/bash
set -euxo pipefail

if [ -d /etc/needrestart/conf.d ]; then
    echo "\$nrconf{restart} = 'a';" | sudo tee /etc/needrestart/conf.d/50local.conf
fi

if [ ! -f /etc/apt/apt.conf.d/50local ]; then
    echo 'APT::Get::Purge 1;' | sudo tee /etc/apt/apt.conf.d/50local
fi

sudo apt update
#apt list --upgradable
sudo apt install -y etckeeper
trap "sudo etckeeper vcs gc" EXIT
