#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")"

base=ubuntu-22.04-server-cloudimg-riscv64.img
if [ ! -f "$base" ]; then
    curl -LO "https://cloud-images.ubuntu.com/releases/22.04/release/$base"
fi
img=diff.img
if [ ! -f "$img" ]; then
    qemu-img create -f qcow2 -b "$base" -F qcow2 "$img"
    qemu-img resize "$img" +5G
fi
if [ ! -f config/meta-data ]; then
    echo "instance-id: $(uuidgen || echo i-abcdefg)" > config/meta-data
fi
cidata=seed.iso
if [ -x /usr/bin/cloud-localds ]; then
    cloud-localds "$cidata" config/user-data config/meta-data
else
    rm -f "$cidata"
    # hblkid で TYPE="hfsplus" に見えていると認識されないので -hfs はつけない。
    hdiutil makehybrid -o "$cidata" -joliet -iso -default-volume-name cidata config/
fi

fw=/usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin
if [ ! -f "$fw" ]; then
    fw=$(echo /opt/homebrew/Cellar/qemu/*/share/qemu/opensbi-riscv64-generic-fw_dynamic.bin)
fi
uboot=/usr/lib/u-boot/qemu-riscv64_smode/uboot.elf
# riscv64 用の uboot は homebrew の qemu に入っていなかったのでコピーしてきた。
if [ -f uboot.elf ]; then
    uboot=uboot.elf
fi

args=(
    -machine virt
    -nographic
    -m 2048
    -smp 4
    -bios "$fw"
    -kernel "$uboot"
    -device "virtio-net-device,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::2222-:22"
    -device virtio-rng-pci
    -drive "if=virtio,format=qcow2,file=$img"
    -drive "if=virtio,format=raw,file=$cidata"
)

if [ -d shared ]; then
    args=(
        "${args[@]}"
        # mount -t 9p -o trans=virtio test_mount /tmp/shared/ -oversion=9p2000.L,posixacl,msize=104857600
        -virtfs "local,path=./shared,mount_tag=test_mount,security_model=mapped-xattr"
    )
fi

exec qemu-system-riscv64 "${args[@]}"
