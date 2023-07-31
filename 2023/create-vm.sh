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
#time limactl shell $name sudo btrfs subvolume delete /ext2_saved

time limactl shell $name sudo apt update
time limactl shell $name sudo DEBIAN_FRONTEND=noninteractive apt install -y etckeeper

time limactl shell $name sudo tee /etc/needrestart/conf.d/50-autorestart.conf <<<"\$nrconf{restart} = 'a';"
time limactl shell $name sudo etckeeper commit 'Set needrestart auto'

time limactl shell $name sudo DEBIAN_FRONTEND=noninteractive apt install -y btrfsmaintenance
time limactl shell $name sudo systemctl enable --now btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer
time limactl shell $name sudo etckeeper commit 'enable btrfsmaintenance timers'

time limactl shell $name sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
time limactl shell $name sudo DEBIAN_FRONTEND=noninteractive apt autoremove --purge -y

time limactl shell $name sudo btrfs subvolume snapshot / /@
time limactl shell $name sudo mkdir /@/mnt/btr_pool
time limactl shell $name sudo tee -a /@/etc/fstab <<<"LABEL=cloudimg-rootfs /mnt/btr_pool btrfs subvolid=5 0 0"
for d in home var/log tmp var/tmp var/cache var/lib/snapd var/snap snap var/lib/docker; do
    if limactl shell $name test -d /@/$d; then
        time limactl shell $name sudo btrfs subvolume create /@${d//\//_}
        time limactl shell $name sudo find /@/$d -maxdepth 1 -mindepth 1 -exec mv -t /@${d//\//_} '{}' +
        time limactl shell $name sudo tee -a /@/etc/fstab <<<"LABEL=cloudimg-rootfs /$d btrfs subvol=@${d//\//_} 0 0"
    fi
done
time limactl shell $name sudo btrfs subvolume set-default /@

if limactl shell $name test -d /@/var/lib/docker; then
    time limactl shell $name sudo tee /@/etc/docker/daemon.json <<<"{\n  \"storage-driver\": \"btrfs\"\n}\n"
fi

time limactl stop $name
time limactl start $name

time limactl shell $name sudo btrfs subvolume delete /mnt/btr_pool/ext2_saved
time limactl shell $name sudo rm -rf /mnt/btr_pool/[A-Za-z]*
time limactl shell $name sudo etckeeper vcs gc
