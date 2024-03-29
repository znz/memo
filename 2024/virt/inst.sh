#!/bin/bash

# ./inst.sh
# env arch=riscv64 ./inst.sh

set -euxo pipefail
cd "$(dirname "$0")"
umask 027

: ${osver=22.04}
: ${arch=amd64}

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

imgdir=/srv/libvirt-qemu-images
install -m 750 -o libvirt-qemu -g libvirt-qemu -d "$imgdir"
img="$imgdir/$name.img"
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

cidata="$name/cidata.iso"
cloud-localds "$cidata" "$name/user-data" "$name/meta-data"

install -m 1777 -o root -g root -d "shared"
install -m 775 -o libvirt-qemu -g libvirt-qemu -d "$name/home_chkbuild"
# apt install attr
# attr -q -g virtfs.uid jammy-amd64/home_chkbuild | hexdump -C
printf '\xe9\x03\x00\x00' | attr -q -s virtfs.uid "$name/home_chkbuild"
printf '\xe9\x03\x00\x00' | attr -q -s virtfs.gid "$name/home_chkbuild"

args=(
    "${args[@]}"
    --name "$name"
    --ram=2048
    --vcpu=2
    --osinfo "$osinfo"

    --import
    --disk "path=$img,format=raw"
    --disk "path=$cidata,device=cdrom"

    --network "network=default"
    --graphics none

    --filesystem "type=mount,accessmode=mapped,source=$PWD/$name/home_chkbuild,target=home_chkbuild"
    --filesystem "type=mount,accessmode=mapped,source=$PWD/shared,target=test_mount"
)

exec virt-install "${args[@]}"

cat >/dev/null <<EOF
+ exec virt-install --virt-type qemu --arch x86_64 --name jammy-amd64 --ram=2048 --vcpu=2 --osinfo ubuntu22.04 --import --disk path=/srv/libvirt-qemu-images/jammy-amd64.img,format=raw --disk path=jammy-amd64/cidata.iso,device=cdrom --network network=default --graphics none --filesystem type=mount,accessmode=mapped,source=/srv/jammy-amd64/home_chkbuild,target=home_chkbuild --filesystem type=mount,accessmode=mapped,source=/srv/shared,target=test_mount

Starting install...
Creating domain...                                                                                                                                                             |    0 B  00:00:00
Running text console command: virsh --connect qemu:///system console jammy-amd64
Connected to domain 'jammy-amd64'
EOF

# dd if=/dev/zero of=/tmp/write.tmp ibs=1M obs=1M count=1024
# sudo dd if=/dev/zero of=/mnt/shared/write.tmp ibs=1M obs=1M count=1024
