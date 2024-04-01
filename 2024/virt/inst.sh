#!/bin/bash

# How to use:
#
#   env arch=riscv64 ./inst.sh
#   virsh autostart jammy-riscv64
#
# How to prepare:
#
#   apt install qemu-system-misc qemu-utils u-boot-qemu
#   apt install libvirt-daemon-system virtinst libvirt-clients uuid-runtime
#
#   virsh net-start default
#   resolvectl mdns virbr0 yes
#
# How to revert changes:
#
#   virsh destroy jammy-riscv64
#   virsh undefine jammy-riscv64
#   virsh vol-delete --vol jammy-riscv64.img --pool libvirt-qemu-images
#   virsh vol-delete --vol jammy-riscv64.iso --pool libvirt-qemu-images
#   virsh pool-destroy --pool libvirt-qemu-images
#   virsh pool-delete --pool libvirt-qemu-images
#   virsh pool-undefine --pool libvirt-qemu-images
#   virsh net-destroy default
#   rm ubuntu-22.04-server-cloudimg-riscv64.img
#
# How to auto-start:
#
#   virsh net-autostart default
#   virsh autostart jammy-riscv64


set -euxo pipefail
cd "$(dirname "$0")"
umask 027

: ${osver=22.04}
: ${arch=amd64}
: ${ram=2048}
: ${vcpu=4}
: ${storage_dir=/srv/libvirt-qemu-images}


case "$arch" in
    amd64)
	args=(
	    --arch x86_64
	)
	;;
    riscv64)
	arch2="$arch"
	args=(
	    --virt-type qemu
	    --machine virt
	    --arch "$arch"
	    --boot "kernel=/usr/lib/u-boot/qemu-riscv64_smode/uboot.elf"
	)
	;;
esac

case "$osver" in
    22.04)
	codename=jammy
	osinfo=ubuntu22.04
	;;
esac

: ${name="$codename-$arch"}

base="ubuntu-${osver}-server-cloudimg-${arch}.img"
if [ ! -f "$base" ]; then
    wget -N "https://cloud-images.ubuntu.com/releases/$osver/release/$base"
fi

install -m 750 -o libvirt-qemu -g libvirt-qemu -d "$storage_dir"
img="$storage_dir/$name.img"
if [ ! -f "$img" ]; then
    qemu-img convert -f qcow2 -O raw "$base" "$img"
    qemu-img resize "$img" +5G
    chown libvirt-qemu:libvirt-qemu "$img"
fi

install -m 2755 -o root -g libvirt-qemu -d "$name"

if [ ! -f "$name/meta-data" ]; then
    # apt install uuid-runtime
    echo "instance-id: $(uuidgen || echo i-abcdefg)" > "$name/meta-data"
fi

erb "arch=$arch" "osver=$osver" "codename=$codename" "name=$name" config/user-data > "$name/user-data"

cidata="$storage_dir/$name.iso"
cloud-localds "$cidata" "$name/user-data" "$name/meta-data"

install -m 1775 -o root -g libvirt-qemu -d "shared"

args=(
    "${args[@]}"
    --name "$name"
    --ram "$ram"
    --vcpu "$vcpu"
    --osinfo "$osinfo"

    --import
    --disk "path=$img,format=raw"
    --disk "path=$cidata,device=cdrom"

    --network "network=default"
    --graphics none

    --filesystem "type=mount,accessmode=mapped,source=$PWD/shared,target=test_mount"
)

exec virt-install "${args[@]}"
