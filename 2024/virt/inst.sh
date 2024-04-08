#!/bin/bash

# How to use:
#
#   ./inst.sh
#   sudo virsh autostart jammy-riscv64
#
# Other examples:
#   env codename=noble arch=amd64 ./inst.sh
#
# How to prepare:
#
#   sudo apt install qemu-system-misc qemu-utils u-boot-qemu
#   sudo apt install libvirt-daemon-system virtinst libvirt-clients
#
#   (for uuidgen)
#   sudo apt install uuid-runtime
#   (for erb)
#   sudo apt install ruby
#
#   sudo virsh net-start default
#   sudo resolvectl mdns virbr0 yes
#
# How to revert changes:
#
#   sudo virsh destroy jammy-riscv64
#   sudo virsh undefine jammy-riscv64
#   sudo virsh vol-delete --vol jammy-riscv64.img --pool libvirt-qemu-images
#   sudo virsh vol-delete --vol jammy-riscv64.iso --pool libvirt-qemu-images
#   sudo virsh pool-destroy --pool libvirt-qemu-images
#   sudo virsh pool-delete --pool libvirt-qemu-images
#   sudo virsh pool-undefine --pool libvirt-qemu-images
#   sudo virsh net-destroy default
#   rm ubuntu-22.04-server-cloudimg-riscv64.img
#
# How to auto-start:
#
#   sudo virsh net-autostart default
#   sudo virsh autostart jammy-riscv64


set -euxo pipefail
cd "$(dirname "$0")"
umask 027

: ${codename=jammy}
: ${arch=riscv64}
: ${ram=2048}
: ${vcpu=2}
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

case "$codename" in
    jammy)
	osinfo=ubuntu22.04
	;;
    noble)
	osinfo=ubuntu22.04
	;;
esac

: ${name="$codename-$arch"}

base="${codename}-server-cloudimg-${arch}.img"
if [ ! -f "$base" ]; then
    wget -N "https://cloud-images.ubuntu.com/$codename/current/$base"
fi

sudo install -m 755 -o libvirt-qemu -g libvirt-qemu -d "$storage_dir"
img="$storage_dir/$name.img"
if [ ! -f "$img" ]; then
    sudo qemu-img convert -f qcow2 -O raw "$base" "$img"
    # sudo qemu-img resize "$img" +5G
    sudo qemu-img resize "$img" 16G
    sudo chown libvirt-qemu:libvirt-qemu "$img"
fi

mkdir -p "$name"

if [ ! -f "$name/meta-data" ]; then
    # apt install uuid-runtime
    echo "instance-id: $(uuidgen || echo i-abcdefg)" > "$name/meta-data"
fi

erb "arch=$arch" "codename=$codename" "name=$name" config/user-data > "$name/user-data"

cidata="$storage_dir/$name.iso"
sudo cloud-localds "$cidata" "$name/user-data" "$name/meta-data"

sudo install -m 1775 -o 1000 -g libvirt-qemu -d "shared"

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

exec sudo virt-install "${args[@]}"
