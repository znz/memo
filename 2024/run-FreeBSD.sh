#!/bin/bash
set -euxo pipefail
cd ~/tmp

URL=https://download.freebsd.org/releases/VM-IMAGES/14.1-RELEASE/aarch64/Latest/FreeBSD-14.1-RELEASE-arm64-aarch64.qcow2.xz
IMAGE_XZ=$(basename "$URL")
IMAGE=$(basename "$IMAGE_XZ" .xz)


if [ ! -f "$IMAGE_XZ" ]; then
    curl -LO "$URL"
fi
if [ ! -f "$IMAGE" ]; then
    unxz -k "$IMAGE_XZ"
fi
exec qemu-system-aarch64 -M virt -cpu max -bios /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd -m 2g -smp 4 -serial mon:stdio -nographic -device virtio-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22 "$IMAGE"
