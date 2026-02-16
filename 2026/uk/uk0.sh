!/bin/bash
set -euxo pipefail

VM_NAME=uk0

trap 'echo $?; date' 0

DIR=$(cd $(dirname "$0") && pwd)

run () {
    limactl shell "$VM_NAME" "$@" </dev/null
}

sudo () {
    run sudo "$@"
}

run_ansible () {
    run bash -euc 'cd; . kubespray-offline/outputs/venv.sh; set -x; ansible localhost -c local -e ansible_python_interpreter=auto_silent "$0" "$@"' "$@"
}

# default: --memory 4 --cpus 4 --disk 100
limactl start template:ubuntu-lts --name "$VM_NAME" --containerd none --set '.provision += [{"mode":"system","script":"sysctl fs.inotify.max_user_instances=1280 fs.inotify.max_user_watches=1048576"}]' --network=lima:user-v2 --tty=false || echo $?

sudo apt-get update -q || echo $?
sudo apt-get install etckeeper -qy || echo $?
run bash -exc 'grep -q $HOSTNAME /etc/hosts || echo "$(hostname -I) $HOSTNAME" | sudo tee -a /etc/hosts'
sudo etckeeper commit "Add hostname to /etc/hosts" || :
sudo apt-get full-upgrade -V -qy || echo $?
sudo apt-get purge nano -y || echo $?
sudo etckeeper vcs gc || echo $?

sudo bash -ec "grep -q PS1:+set /etc/bash.bashrc || git -C /etc apply '$DIR/patches/bash.bashrc.diff'"
sudo etckeeper commit "Fix bash.bashrc with set -u" || :
sudo git -C /etc apply "$DIR/patches/ufw-before.diff" || :
sudo etckeeper commit "Patch ufw-before" || :

limactl stop "$VM_NAME" || :
limactl start "$VM_NAME"

: sudo bash -euxc '
mkdir -p  /etc/containers/registries.conf.d
cat >/etc/containers/registries.conf.d/mirror.conf <<EOF
[[registry]]
location = "docker.io"
[[registry.mirror]]
location = "mirror.gcr.io"
EOF
'
: sudo etckeeper commit "Use docker registry mirror" || :

run bash -euxc '
cd
test -d kubespray-offline ||
git clone https://github.com/kubespray-offline/kubespray-offline
cd kubespray-offline
git switch --detach v2.30.0-0
cp -p '"$DIR"'/imagelists/*.txt imagelists/
echo nfs-common > pkglist/ubuntu/nfs.txt
test -d outputs ||
time ./download-all.sh
cp -p '"$DIR"'/patches/outputs/*.sh outputs/
find outputs -type f | sort > outputs-$(date -I).list.txt
tar acvf outputs-$(date -I).tar.gz outputs
'

# arm64 のイメージがないと
# msg="image might be filtered out (Hint: set `--platform=PLATFORM` or `--all-platforms`)"
# で ./load-push-all-images.sh が失敗するため、amd64 だけのイメージは削除する。
run bash -euxc '
target_arch=$(dpkg --print-architecture)
cd
cd kubespray-offline/outputs
if test -f deleted-images.list; then
    exit
fi
touch deleted-images.list
for image in images/*.tar.gz; do
    found=false
    for config in $(tar xf "$image" manifest.json -O | jq -r ".[].Config"); do
        architecture=$(tar xf "$image" "$config" -O | jq -r .architecture)
        if test "$target_arch" = "$architecture"; then
            found=true
        fi
    done
    if ! $found; then
        for tag in $(tar xf "$image" manifest.json -O | jq -r ".[].RepoTags.[]"); do
            echo "$tag" >> deleted-images.list
            sed -i "/${tag//\//.}/d" images/*.list
        done
        rm $image
    fi
done
'

run bash -euxc '
target_arch=$(dpkg --print-architecture)
tar -C /tmp -xf ~/kubespray-offline/outputs/files/helm-*-linux-$target_arch.tar.gz linux-$target_arch/helm
sudo install /tmp/linux-$target_arch/helm /usr/local/bin/helm
'

run bash -euxc '
cd ~/kubespray-offline/outputs
if test -d charts/cilium; then
    exit
fi
mkdir -p charts
cd charts
helm repo add cilium https://helm.cilium.io/
helm repo update
helm pull cilium/cilium --untar --version 1.18.4
mv cilium cilium-1.18.4
helm pull cilium/cilium --untar --version 1.18.6
mv cilium cilium-1.18.6
'

run bash -euxc '
cd ~/kubespray-offline/outputs/files
if test -f k9s_linux_arm64.deb; then
    exit
fi
URL=https://github.com/derailed/k9s/releases/download/v0.50.18/k9s_linux_arm64.deb
curl -LO $URL
echo $URL >> additional-files.list
'

rsync -avz patches/outputs/ lima-$VM_NAME:kubespray-offline/outputs/

# nfs server
sudo apt-get install nfs-kernel-server -y
# sudo sed -i -e '/# vers3=y/i vers2=n' -e 's/# vers3=y/vers3=n/' /etc/nfs.conf
sudo bash -euc 'printf "[nfsd]\nvers2=n\nvers3=n\n" > /etc/nfs.conf.d/disable-ver3.conf'
sudo systemctl mask --now rpc-statd.service rpcbind.socket rpcbind.service
sudo etckeeper commit "Disable nfs3" || :
sudo systemctl restart nfs-mountd.service

sudo mkdir -p /exports
run_ansible -b -m ansible.builtin.lineinfile -a '{"path": "/etc/exports", "search_string": "^{{ dir }} ", "line": "{{ dir }} *(rw,fsid=0,sync,no_subtree_check,no_root_squash,insecure)", "owner": "root", "group": "root", "mode": "0644"}' -e dir=/exports
sudo etckeeper commit "Export /exports" || :
sudo systemctl restart nfs-mountd.service

HOME_IN_LIMA=$(ssh "lima-$VM_NAME" pwd)
sudo mkdir -p "/exports/outputs"
run_ansible -b -m ansible.builtin.lineinfile -a '{"path": "/etc/exports", "search_string": "^{{ dir }} ", "line": "{{ dir }} *(rw,sync)", "owner": "root", "group": "root", "mode": "0644"}' -e dir="/exports/outputs"
run_ansible -b -m ansible.builtin.lineinfile -a '{"path": "/etc/fstab", "search_string": " {{ dir }} ", "line": "{{ src }} {{ dir }} none bind 0 0", "owner": "root", "group": "root", "mode": "0644"}' -e src="$HOME_IN_LIMA/kubespray-offline/outputs" -e dir="/exports/outputs"
sudo etckeeper commit "Export /exports/outputs" || :
sudo systemctl daemon-reload
sudo mount -a
sudo systemctl restart nfs-mountd.service
