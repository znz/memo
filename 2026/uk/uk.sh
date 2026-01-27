#!/bin/bash
set -euxo pipefail

trap 'echo $?; date' 0

DIR=$(cd $(dirname "$0") && pwd)
VM_NAME=uk0
prefix=uk
first=1
max=3

run_all () {
    for i in $(seq 1 $max); do
        limactl shell "$prefix$i" "$@" </dev/null &
    done
    wait
}

run_first () {
    limactl shell "$prefix$first" "$@" </dev/null
}

run_rest () {
    for i in $(seq 2 $max); do
        limactl shell "$prefix$i" "$@" </dev/null &
    done
    wait
}

sudo () {
    run_all sudo "$@"
}

run_in_venv () {
    run_first bash -euc 'cd ~/outputs/kubespray-*; source ../venv.sh; set -x; "$0" "$@"' "$@"
}

run_ansible_playbook () {
    run_in_venv ansible-playbook "$@"
}

run_ansible () {
    run_in_venv ansible -e ansible_python_interpreter=auto_silent "$@"
}

limactl list
for i in $(seq 1 $max); do
    limactl start template:ubuntu-lts --name "$prefix$i" --containerd none --memory 4 --cpus 4 --disk 100 --set '.provision += [{"mode":"system","script":"sysctl fs.inotify.max_user_instances=1280 fs.inotify.max_user_watches=1048576"}]' --network=lima:user-v2 --tty=false || echo $?
done
limactl list

sudo apt-get update -q || echo $?
sudo apt-get install etckeeper -qy || echo $?
run_all bash -exc 'grep -q $HOSTNAME /etc/hosts || echo "$(hostname -I) $HOSTNAME" | sudo tee -a /etc/hosts'
sudo etckeeper commit "Add hostname to /etc/hosts" || :
# sudo apt-get full-upgrade -V -qy || echo $?
sudo apt-get purge nano -y || echo $?
sudo etckeeper vcs gc || echo $?
sudo bash -ec "grep -q PS1:+set /etc/bash.bashrc || git -C /etc apply '$DIR/patches/bash.bashrc.diff'"
sudo etckeeper commit "Fix bash.bashrc with set -u" || :
sudo apt-get install nfs-common -qy || echo $?

for i in $(seq 1 $max); do
    limactl stop "$prefix$i" || :
    limactl start "$prefix$i"
done

mkdir -p "$DIR/tmp"
inventory_ini="$DIR/tmp/$prefix-inventory.ini"
cat >"$inventory_ini" <<EOF
[kube_control_plane]
EOF

for i in $(seq 1 $max); do
    ip=$(limactl shell "$prefix$i" hostname -I)
    echo "lima-$prefix$i ansible_host=$ip ip=$ip etcd_member_name=etcd$i" >>"$inventory_ini"
    sudo env IP="$ip" NAME="lima-$prefix$i" bash -c 'grep -q $IP /etc/hosts || echo $IP $NAME >> /etc/hosts'
done
sudo etckeeper commit "Add nodes to hosts" || :

cat >>"$inventory_ini" <<EOF
[etcd:children]
kube_control_plane

[kube_node:children]
kube_control_plane
EOF

sudo git -C /etc apply "$DIR/patches/ufw-before.diff" || :

sudo ufw allow 22/tcp comment SSH
sudo ufw allow out 22/tcp comment SSH
sudo ufw allow out 53 comment DNS
sudo ufw allow out 123/udp comment NTP
sudo ufw allow out 22/tcp comment SSH
# sudo ufw allow out 80/tcp comment HTTP
# sudo ufw allow out 443 comment HTTPS
sudo ufw default reject outgoing
sudo ufw --force enable &
sleep 6

# kube-vip の lb-apiserver に必要?
sudo ufw default allow routed

# クラスタ内サブネットの通信を許可する
# 10.233.0.0/18 = 10.233.0.1 - 10.233.63.254
# 10.233.64.0/18 = 10.233.64.1 - 10.233.127.254
sudo ufw allow from 192.168.104.0/24 comment 'eth0 subnet'
sudo ufw allow out to 192.168.104.0/24 comment 'eth0 subnet'
sudo ufw allow from 10.233.0.0/18 comment 'kube_service_addresses'
sudo ufw allow out to 10.233.0.0/18 comment 'kube_service_addresses'
sudo ufw allow from 10.233.64.0/18 comment 'kube_pods_subnet'
sudo ufw allow out to 10.233.64.0/18 comment 'kube_pods_subnet'
sudo ufw allow from 169.254.0.0/16 comment 'IPv4 link-local unicast addresses'
sudo ufw allow out to 169.254.0.0/16 comment 'IPv4 link-local unicast addresses'

# sudo ufw allow to 169.254.25.10 port 9254 comment 'nodelocaldns?'
# sudo ufw delete allow out to 169.254.25.10 port 9254 comment 'nodelocaldns?'

sudo etckeeper commit "Enable ufw" || :

# first で ssh 鍵の生成と全ノードへの追加
run_first bash -euxc 'test -f  ~/.ssh/id_ed25519 || ssh-keygen -f ~/.ssh/id_ed25519 -N ""'
SSH_PUBKEY=$(run_first bash -c 'cat ~/.ssh/id_ed25519.pub')
run_all bash -c "echo $SSH_PUBKEY >> ~/.ssh/authorized_keys"

# outputs の転送
# rsync -avzP ~/tmp/outputs.tar.gz lima-$prefix$first:outputs.tar.gz
# rsync -avzP "$(ls -1 ~/tmp/outputs-*.tar.gz | tail -n1)" "lima-$prefix$first:outputs.tar.gz"

sudo mkdir -p /mnt/outputs /mnt/outputs.lower
for dir in /mnt/outputs.{upper,work}; do
    sudo install -o $(id -u) -g $(id -g) -d "$dir"
done
run_all bash -euc "VM_NAME='$VM_NAME';"'grep -q "^lima-$VM_NAME.internal:/outputs " /etc/fstab || echo lima-$VM_NAME.internal:/outputs /mnt/outputs.lower nfs4 ro,_netdev,x-systemd.automount 0 0 | sudo tee -a /etc/fstab'
run_all bash -euc 'grep -q "^overlay /mnt/outputs " /etc/fstab || echo overlay /mnt/outputs overlay noauto,_netdev,x-systemd.automount,lowerdir=/mnt/outputs.lower,upperdir=/mnt/outputs.upper,workdir=/mnt/outputs.work 0 0 | sudo tee -a /etc/fstab'
sudo systemctl daemon-reload
sudo mount /mnt/outputs.lower
sudo mount /mnt/outputs
sudo install -m 755 -o root -g root -d /etc/systemd/system/mnt-outputs.mount.d
sudo install -m 644 -o root -g root "$DIR/patches/mnt-outputs.mount.override.conf" /etc/systemd/system/mnt-outputs.mount.d/override.conf
sudo etckeeper commit "mount /mnt/outputs" || :

run_first bash -euc "prefix='$prefix';"'
ln -snf /mnt/outputs ~/outputs
cd ~/outputs
./setup-all.sh
./extract-kubespray.sh
cd kubespray-*/
set +x; source ../venv.sh; set -x
pip install -r requirements.txt
cp -r inventory/sample inventory/${prefix}cluster
'

inventory_dir="$(run_first bash -ec 'echo ~/outputs/kubespray-*/inventory')"
remote_inventory_dir="lima-$prefix$first:$inventory_dir"

scp -p "$DIR/patches/inventory/local.yml" "$remote_inventory_dir/${prefix}cluster/group_vars/k8s_cluster/local.yml"
scp -p "$inventory_ini" "$remote_inventory_dir/${prefix}cluster/inventory.ini"

scp -p "$DIR/patches/inventory/offline.yml" "$remote_inventory_dir/${prefix}cluster/group_vars/all/offline.yml"
run_first bash -euxc "inventory_dir='$inventory_dir';prefix='$prefix';"'IPs=($(hostname -I)); sed -i "s/YOUR_HOST/${IPs[0]}/" $inventory_dir/${prefix}cluster/group_vars/all/offline.yml'

time run_ansible_playbook -i "inventory/${prefix}cluster/inventory.ini" -b ../playbook/hosts.yml
time run_ansible_playbook -i "inventory/${prefix}cluster/inventory.ini" -b ../playbook/inotify.yml
time run_ansible_playbook -i "inventory/${prefix}cluster/inventory.ini" -b ../playbook/offline-repo.yml

VIP=$(run_first awk '$1=="kube_vip_address:"{print $2}' "$inventory_dir/${prefix}cluster/group_vars/k8s_cluster/local.yml")
run_ansible all -i "inventory/${prefix}cluster/inventory.ini" -b -m ansible.builtin.lineinfile -a '{"path": "/etc/hosts", "search_string": "{{ kube_vip_address }}", "line": "{{ kube_vip_address }} lb-apiserver.kubernetes.local", "owner": "root", "group": "root", "mode": "0644"}' -e kube_vip_address=$VIP

# time ansible-playbook -i "inventory/${prefix}cluster/inventory.ini" -b cluster.yml; printf "\a\a\a$?\n"; date
time run_ansible_playbook -i "inventory/${prefix}cluster/inventory.ini" -b cluster.yml

# run_all bash -euc '
# if [ ! -f ~/.kube/config ]; then
#     if [ -f /etc/kubernetes/admin.conf ]; then
#         mkdir -p ~/.kube
#         sudo install -m 400 -o $(id -u) -g $(id -g) /etc/kubernetes/admin.conf ~/.kube/config
#     fi
# fi
# '
run_ansible all -i "inventory/${prefix}cluster/inventory.ini" -m ansible.builtin.file -a '{"path": "/home/{{ user }}.linux/.kube", "state": "directory", "mode": "0750"}' -e user=$(id -un)
run_ansible all -i "inventory/${prefix}cluster/inventory.ini" -m ansible.builtin.copy -a '{"remote_src": true, "src": "/etc/kubernetes/admin.conf", "dest": "/home/{{ user }}.linux/.kube/config", "owner": "{{ user }}", "group": "{{ user }}", "mode": "0400"}' -e user=$(id -un) -b

run_ansible all -i "inventory/${prefix}cluster/inventory.ini" -m ansible.builtin.apt -a '{"deb": "{{ deb }}"}' -b -e deb=/mnt/outputs/files/k9s_linux_arm64.deb
