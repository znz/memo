#!/bin/bash
set -euxo pipefail
name=${1?$0 name}
time limactl shell $name sudo btrfs subvolume create /mnt/btr_pool/_btrbk_snap || :
time limactl shell $name sudo DEBIAN_FRONTEND=noninteractive apt install -y btrbk
time limactl shell $name sudo tee /etc/btrbk/btrbk.conf <<EOF
transaction_log            /var/log/btrbk.log
timestamp_format           long-iso
stream_buffer              256m
snapshot_dir               _btrbk_snap

snapshot_preserve_min 2d
snapshot_preserve 14d 4w 6m
snapshot_create onchange

volume /mnt/btr_pool
  subvolume @
  subvolume @root
    snapshot_preserve 24h 30d *m
  subvolume @home
    snapshot_preserve 24h 30d *m
  subvolume @var_log
    snapshot_preserve 24h 30d *m
  subvolume @*tmp
    snapshot_preserve 7d
  subvolume @var_cache
    snapshot_preserve 7d
  subvolume @var_spool
    snapshot_preserve 7d
  subvolume @var_lib_apt
    snapshot_preserve 7d
  subvolume @var_lib_dpkg
    snapshot_preserve 7d
  subvolume @var_lib
  subvolume @*snap*
    group snapd
    snapshot_preserve 7d
EOF
time limactl shell $name sudo tee /etc/apt/apt.conf.d/70btrbk <<'EOF'
// create a btrfs snapshot before (un)installing packages
Dpkg::Pre-Invoke  {"if [ -x /usr/bin/btrbk ]; then /usr/bin/btrbk --preserve snapshot; fi"; };
DPkg::Post-Invoke {"if [ -x /usr/bin/btrbk ]; then /usr/bin/btrbk --preserve snapshot; fi"; };
EOF
time limactl shell $name sudo mkdir -p /etc/systemd/system/btrbk.timer.d
time limactl shell $name sudo tee /etc/systemd/system/btrbk.timer.d/override.conf <<EOF
[Timer]
OnCalendar=hourly
EOF
time limactl shell $name sudo systemctl enable --now btrbk.timer
time limactl shell $name sudo etckeeper commit "Setup btrbk"
time limactl shell $name sudo systemctl start btrbk.service || echo $?
time limactl shell $name sudo journalctl -u btrbk.service --no-pager
