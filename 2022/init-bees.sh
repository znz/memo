#!/bin/bash
set -euxo pipefail
sudo apt-get -y install build-essential btrfs-progs markdown
cd
git clone https://github.com/Zygo/bees
cd bees
sed -i -e 's,/usr/lib/bees/bees,@LIBEXEC_PREFIX@/bees,' scripts/beesd.in
make PREFIX=/usr/local
sudo make PREFIX=/usr/local install

#df --type=btrfs --output=target | tail -n+2
for DEV_TARGET in $(awk '$3=="btrfs"{print $1 "::" $2}' /etc/mtab); do
    DEV=${DEV_TARGET%%::*}
    TARGET=${DEV_TARGET##**}
    UUID=$(lsblk -no UUID "$DEV")
    ESCAPED_TARGET=$(systemd-escape -p "$TARGET")
    sed -e "s/UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/UUID=$UUID/" /etc/bees/beesd.conf.sample | sudo tee "/etc/bees/$ESCAPED_TARGET.conf"
    sudo systemctl enable beesd@$UUID.service --now
done
