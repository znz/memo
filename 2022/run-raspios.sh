#!/bin/bash
set -euxo pipefail
: ${1?usage $0 2022-01-28-raspios-bullseye-arm64-lite.zip}
BASENAME=$(basename "$1" .zip)
DIRNAME=$(dirname "$1")
cd "${DIRNAME}"
if [ ! -f "${BASENAME}.qcow2" ]; then
    7z x "${BASENAME}.zip" >/dev/null
    qemu-img convert -O qcow2 "${BASENAME}.img" "${BASENAME}.qcow2"
    qemu-img resize "${BASENAME}.qcow2" "${2:-8G}"
fi

7z x -y "${BASENAME}.img" 0.fat >/dev/null
7z x -oboot -y 0.fat >/dev/null
rm -f 0.fat

exec qemu-system-aarch64 -m 1024 -M raspi3b -kernel boot/kernel8.img -dtb boot/bcm2710-rpi-3-b-plus.dtb -sd 2022-01-28-raspios-bullseye-arm64-lite.qcow2 -append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4 dwc_otg.fiq_fsm_enable=0" -nographic -serial mon:stdio -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22

# run in raspios
sudo raspi-config --expand-rootfs
rsz () if [[ -t 0 ]]; then local escape r c prompt=$(printf '\e7\e[r\e[999;999H\e[6n\e8'); IFS='[;' read -sd R -p "$prompt" escape r c; stty cols $c rows $r; fi
rsz

sudo apt update
sudo apt install etckeeper
sudo etckeeper vcs gc
sudo apt full-upgrade -V
