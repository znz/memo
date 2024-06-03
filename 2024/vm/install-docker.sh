#!/bin/bash
set -euxo pipefail

if ! test -d /mnt/btr_pool/@var_lib_docker; then
    sudo btrfs subvolume create /mnt/btr_pool/@var_lib_docker
fi
if ! grep -q /var/lib/docker /etc/fstab; then
    awk '$2=="/var/lib"{print}' /etc/fstab | sed -e 's,/lib,/lib/docker,' -e 's,_lib,_lib_docker,' | sudo tee -a /etc/fstab
    sudo systemctl daemon-reload
    sudo mkdir -p /var/lib/docker
    sudo mount /var/lib/docker
fi

if ! test -f /etc/docker/daemon.json; then
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<<$'{\n  "storage-driver": "btrfs"\n}\n'
fi

curl -fsSL https://get.docker.com | sh
sudo adduser $USER docker
