#!/bin/bash
set -euxo pipefail
snap list
time snap remove lxd
time snap remove core20
time snap remove snapd
snap list
apt-get autoremove --purge -y snapd
