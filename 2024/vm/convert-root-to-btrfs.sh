#!/bin/bash
set -euxo pipefail

if ! test -b ${1:?$'\n'"Usage: $0 GRUB_INSTALL_DEVICE"$'\n'"Example: $0 /dev/sda"}; then
    echo $1 is not block device.
    exit 1
fi

if ! test -f /bin/gawk; then
    apt-get update -qy
    apt-get install -y gawk
fi

if ! gawk '$2=="/"&&$3=="ext4"{count+=1}END{if(count!=1){exit(1)}}' /etc/fstab; then
    echo This shell script supports root is ext4 only.
    exit 1
fi

if ! test -f /bin/btrfs-convert; then
    apt-get update -qy
    apt-get install -y btrfs-progs
fi

cat >/etc/initramfs-tools/hooks/0-convert-root-to-btrfs <<'EOF'
#!/bin/sh

set -e

PREREQS=""

prereqs() { echo "$PREREQS"; }

case $1 in
    prereqs)
          prereqs
          exit 0
    ;;
esac

. /usr/share/initramfs-tools/hook-functions

copy_exec /bin/btrfs-convert

# Workaround for `libgcc_s.so.1 must be installed for pthread_cancel to work`
# see /run/btrfs-convert.log
if test -f /usr/lib/aarch64-linux-gnu/libgcc_s.so.1; then
    copy_exec /usr/lib/aarch64-linux-gnu/libgcc_s.so.1
fi

exit 0
EOF
chmod +x /etc/initramfs-tools/hooks/0-convert-root-to-btrfs
cat >/etc/initramfs-tools/scripts/init-premount/convert-root-to-btrfs <<'EOF'
#!/bin/sh

set -e

PREREQ=""

prereqs()
{
    echo "${PREREQ}"
}

case "${1}" in
    prereqs)
        prereqs
        exit 0
        ;;
esac

case "${ROOT}" in
    UUID=*)
        ROOTDEV=/dev/disk/by-uuid/${ROOT#UUID=}
        ;;
    LABEL=*)
        ROOTDEV=/dev/disk/by-label/${ROOT#LABEL=}
        ;;
    PARTUUID=*)
        ROOTDEV=/dev/disk/by-partuuid/${ROOT#PARTUUID=}
        ;;
    *)
        ROOTDEV=${ROOT}
        ;;
esac

exec >/run/btrfs-convert.log 2>&1
if /bin/btrfs-convert "$ROOTDEV"; then
    echo converted.
fi

exit 0
EOF
chmod +x /etc/initramfs-tools/scripts/init-premount/convert-root-to-btrfs
update-initramfs -u -k all
#lsinitramfs /boot/initrd.img-* | grep btrfs

gawk -i inplace '$2=="/"&&$3=="ext4"{$3="btrfs"; $4="defaults,lazytime,commit=300,compress=zstd"; $5="0";$6="0";}1' /etc/fstab

# After reboot:
#
# sudo grub-install --recheck /dev/vda
# sudo update-grub
cat >/etc/systemd/system/grub-recheck.service <<"EOF"
[Unit]
Description=grub-install --recheck after convert root to btrfs

[Service]
Type=oneshot
ExecStart=/usr/sbin/grub-install --recheck $1
ExecStart=/usr/sbin/update-grub
ExecStart=/usr/bin/systemctl disable grub-recheck.service

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl enable grub-recheck.service

# After converted:
# sudo btrfs filesystem defragment -r -v -czstd /
# sudo btrfs quota enable /
# sudo btrfs quota rescan /
# sudo btrfs scrub start /
#
# sudo btrfs subvolume delete /ext2_saved
#
# sudo apt install btrfsmaintenance
# sudo systemctl enable --now btrfs-balance.timer btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer
