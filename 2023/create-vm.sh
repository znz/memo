#!/bin/bash
set -euxo pipefail
name=${1?$0 name template}
template=${2:-ubuntu-lts}
dir=$(dirname "$0")

time limactl start --name=$name template://$template

time limactl shell $name sudo bash $dir/convert-root-to-btrfs.sh /dev/vda
time limactl stop $name
time limactl start $name
time limactl shell $name sudo btrfs filesystem defragment -r -v -czstd /
time limactl shell $name sudo btrfs quota enable /
time limactl shell $name sudo btrfs quota rescan / || :
time limactl shell $name sudo btrfs scrub start /
time limactl shell $name sudo btrfs subvolume delete /ext2_saved

time limactl shell $name sudo apt update
time limactl shell $name sudo apt install -y etckeeper

time limactl shell $name bash -c 'sudo tee /etc/needrestart/conf.d/50-autorestart.conf <<<"\$nrconf{restart} = '"'a'"';"'
time limactl shell $name sudo etckeeper commit 'Set needrestart auto'

time limactl shell $name sudo apt install -y btrfsmaintenance
time limactl shell $name sudo systemctl enable --now btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer
time limactl shell $name sudo etckeeper commit 'enable btrfsmaintenance timers'

time limactl shell $name sudo apt full-upgrade -y
time limactl shell $name sudo apt autoremove --purge -y

time limactl stop $name
time limactl start $name
