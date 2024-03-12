#!/bin/bash
set -euxo pipefail
if [ ! -f ubuntu-22.04.4-preinstalled-server-riscv64+unmatched.img.xz ]; then
	    wget -N https://cdimage.ubuntu.com/releases/22.04.4/release/ubuntu-22.04.4-preinstalled-server-riscv64+unmatched.img.xz
fi
if [ ! -f ubuntu-22.04.4-preinstalled-server-riscv64+unmatched.img ]; then
	    xz -dk ubuntu-22.04.4-preinstalled-server-riscv64+unmatched.img.xz
	        qemu-img resize -f raw ubuntu-22.04.4-preinstalled-server-riscv64+unmatched.img +5G
fi
if [ ! -f metadata.yaml ]; then
	    echo "instance-id: $(uuidgen || echo i-abcdefg)" > metadata.yaml
fi
cloud-localds my-seed.img user-data.yaml metadata.yaml
qemu-system-riscv64 -machine virt -nographic -m 2048 -smp 4 -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin -kernel /usr/lib/u-boot/qemu-riscv64_smode/uboot.elf -device virtio-net-device,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-rng-pci -drive file=ubuntu-22.04.4-preinstalled-server-riscv64+unmatched.img,format=raw,if=virtio -drive if=virtio,format=raw,file=my-seed.img
