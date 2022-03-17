#!/bin/bash
set -euxo pipefail
sudo apt-get install -y systemd-container
sudo mkdir -p /etc/systemd/system/systemd-nspawn@.service.d
printf "[Service]\nEnvironment=SYSTEMD_NSPAWN_TMPFS_TMP=0\n" | sudo tee /etc/systemd/system/systemd-nspawn@.service.d/override.conf

sudo apt-get install -y btrfs-progs
sudo fallocate -l 50G /machines.img
sudo mkfs.btrfs /machines.img
echo /machines.img /var/lib/machines btrfs defaults,lazytime,compress=zstd:5 0 0 | sudo tee -a /etc/fstab
sudo mount /var/lib/machines

sudo apt-get install -y debootstrap
sudo apt-get install -y mmdebstrap
sudo apt-get install -y debian-archive-keyring debian-ports-archive-keyring ubuntu-keyring
sudo apt-get install -y binfmt-support qemu-user-static
