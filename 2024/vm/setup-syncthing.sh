#!/bin/bash
set -euxo pipefail
name=${1?$0 name}

host_device_id=$(syncthing --device-id)
host_name=$(hostname -s)

time limactl shell $name sudo DEBIAN_FRONTEND=noninteractive apt install -y syncthing
time limactl shell $name bash -c 'sudo systemctl enable --now syncthing@$(id -un)'
time limactl shell $name syncthing cli config devices add --device-id "$host_device_id" --name "$host_name" --auto-accept-folders

guest_device_id=$(limactl shell $name syncthing --device-id)
guest_name=$(limactl shell $name hostname -s)

time syncthing cli config devices add --device-id "$guest_device_id" --name "$guest_name"
