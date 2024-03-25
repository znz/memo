#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")"

# 22.04 は cloud-init が
# [FAILED] Failed to start Initial cloud-init job (pre-networking).
# で失敗していて、別マシンにディスクを接続して確認すると、SEGV していた。

base=ubuntu-23.10-server-cloudimg-ppc64el.img
if [ ! -f "$base" ]; then
    curl -LO "https://cloud-images.ubuntu.com/releases/23.10/release/$base"
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

args=(
    # https://wiki.freebsd.org/powerpc/QEMU
    # -machine pseries,accel=kvm,cap-cfpc=broken,cap-sbbc=broken,cap-ibs=broken
    -machine pseries,cap-cfpc=broken,cap-sbbc=broken,cap-ibs=broken,cap-ccf-assist=off
    -nographic
    -m 2048
    -smp 4
    # qemu-system-ppc64 -help
    # qemu-system-ppc64 -device help
    -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::2222-:22"
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

exec qemu-system-ppc64 "${args[@]}"
