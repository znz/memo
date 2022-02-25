#!/bin/bash
set -euxo pipefail
sudo apt-get install -y build-essential btrfs-progs markdown
cd
git clone https://github.com/Zygo/bees --depth=1
cd bees
make PREFIX=/usr/local
sudo make PREFIX=/usr/local install

# 手動で実行するなら
# sudo btrfs sub create /var/lib/machines/.beeshome
# sudo /usr/local/lib/bees/bees /var/lib/machines

DEVFILE=/50G.img
MOUNTPOINT=/var/lib/machines

UUID=$(blkid -s UUID -o value "$DEVFILE")
PATHNAME=$(systemd-escape -p "$MOUNTPOINT")
sudo btrfs sub create "$MOUNTPOINT"/.beeshome || :
sudo cp /etc/bees/beesd.conf.sample /etc/bees/"$PATHNAME".conf
sudo sed -i -e "s/UUID=.*/UUID=$UUID/" /etc/bees/"$PATHNAME".conf
sudo systemctl enable beesd@$UUID.service --now

# `/run/bees/mnt/$uuid` 以下に `mount --make-private` でマウントされて動くが、
# `/var/lib/machines/.beeshome` は共通だった。
# `/run/bees/$UUID.status` があった。
# 止めると `/run/bees` は消えた。(https://www.freedesktop.org/software/systemd/man/systemd.exec.html の `RuntimeDirectory=bees`)
