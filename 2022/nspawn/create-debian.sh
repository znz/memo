#!/bin/bash
#!/bin/bash
set -euxo pipefail
guest_name=${1?usage: $0 machine_name [arch [suite]]}
arch=${2:-$(dpkg-architecture -q DEB_HOST_ARCH)}
suite=${3:-sid}
tar="${TMPDIR:-/tmp}/$guest_name.tar"

args=(
    --arch=$arch
    --include=dbus # ホスト側からの machinectl shell などに必須
    --aptopt='Apt::Install-Recommends true' # mmdebstrap は false がデフォルト
    --aptopt='APT::Get::Purge 1' # remove 時に --purge をデフォルトにする
    --include bash-completion # shell を使うので
    --include etckeeper # いつも入れているので
    # --include tzdata # すでに入っている
    # 起動時に自動でホスト側と同じ /etc/localtime に設定されるので dpkg-configure tzdata 直後しか影響がなくて無駄
    # --essential-hook='echo tzdata tzdata/Areas select Asia | chroot "$1" debconf-set-selections'
    # --essential-hook='echo tzdata tzdata/Zones/Asia select Tokyo | chroot "$1" debconf-set-selections'
    --include locales # 日本語ロケールも入れてデフォルトは C.UTF-8 にしておく
    --essential-hook='echo locales locales/locales_to_be_generated multiselect ja_JP.UTF-8 UTF-8 | chroot "$1" debconf-set-selections'
    --essential-hook='echo locales locales/default_environment_locale select C.UTF-8 | chroot "$1" debconf-set-selections'
    # パスワードなしに
    --customize-hook='chroot "$1" passwd --delete root'
    # 一般ユーザー作成
    --customize-hook='chroot "$1" useradd --home-dir /home/user --create-home -s /bin/bash user'
    --customize-hook='chroot "$1" passwd --delete user'
    # sudo を許可
    --include sudo
    --customize-hook='echo "user ALL=(ALL) NOPASSWD:ALL" | chroot "$1" tee /etc/sudoers.d/50-local-user'
    # ホスト名を設定
    --customize-hook='echo '"$guest_name"' > "$1/etc/hostname"'
    --customize-hook='echo "127.0.1.1 '"$guest_name"'" >> "$1/etc/hosts"'
)

# network
case "$arch" in
    arm64)
        # systemd-networkd で自動設定
	#
	# systemd-networkd[70]: Could not create manager: Protocol not supported
	# になる環境ではあきらめる。
        args=(
            "${args[@]}"
            --customize-hook='chroot "$1" mv /etc/network/interfaces /etc/network/interfaces.save'
            --customize-hook='chroot "$1" systemctl enable systemd-networkd systemd-resolved'
        )
        ;;
    *)
        # /etc/network/interfaces で設定
        args=(
            "${args[@]}"
            --customize-hook='printf "auto host0\niface host0 inet dhcp\n" > "$1"/etc/network/interfaces.d/host0'
        )
        ;;
esac

# apt-line
case "$arch" in
    alpha|hppa|ia64|m68k|powerpc|ppc64|riscv64|sh4|sparc64|x32)
        # https://deb.debian.org/debian-ports/ にあるもの
        args=(
            "${args[@]}"
            --keyring=/usr/share/keyrings
            --include debian-ports-archive-keyring
        )
        mirror=https://deb.debian.org/debian-ports
        ;;
    *)
        args=(
            "${args[@]}"
            #--components="main contrib non-free"
        )
        #mirror=https://deb.debian.org/debian
        ;;
esac

# useradd warning: systemd-network's uid 102 outside of the UID_MIN 1000 and UID_MAX 60000 range.
# chfn: PAM: System error
# adduser: `/usr/bin/chfn -f systemd Time Synchronization systemd-timesync' returned error code 1. Exiting.
# や
# Setting up systemd-timesyncd (247.3-6) ...
# chfn: PAM: System error
# adduser: `/usr/bin/chfn -f systemd Time Synchronization systemd-timesync' returned error code 1. Exiting.
# になる環境で設定が一部不十分になるがエラーよりましなので対処する
case "$arch:$suite" in
    mips:buster \
        | mips64el:bullseye \
        | mipsel:bullseye \
        | alpha:sid \
        | hppa:sid )
        args=(
            "${args[@]}"
            --essential-hook='chroot "$1" dpkg-divert --rename /usr/bin/chfn'
            --essential-hook='chroot "$1" ln -s /bin/true /usr/bin/chfn'
            --customize-hook='chroot "$1" rm /usr/bin/chfn'
            --customize-hook='chroot "$1" dpkg-divert --remove --rename /usr/bin/chfn'
        )
        ;;
esac

mmdebstrap "${args[@]}" "$suite" "$tar" ${mirror:-}
sudo machinectl import-tar "$tar" "$guest_name"
sudo systemctl start "systemd-nspawn@$guest_name"
echo Run "'sudo machinectl shell $guest_name'" to open shell
# su - user
# ~/init-ruby-build.sh
for f in home/user/*; do
    sudo machinectl copy-to "$guest_name" "$f" "/$f"
done
# poweroff
# sudo machinectl remove $guest_name
#
# usage:
# debian:
# ./create-debian.sh sid-arm64
# ./create-debian.sh mips-buster mips buster
## 古さによる微妙さがある。 ca-certificates が古くて https が通らないことがあるなど。
# ./create-debian.sh s390x-bullseye s390x bullseye
# ./create-debian.sh ppc64el-bullseye ppc64el bullseye
# ./create-debian.sh mipsel-bullseye mipsel bullseye
# ./create-debian.sh mips64el-bullseye mips64el bullseye
# ./create-debian.sh i386-bullseye i386 bullseye
# debian-ports:
# ./create-debian.sh alpha-sid alpha sid
## git-man が入らない, sudo が壊れている
# ./create-debian.sh hppa-sid hppa sid
## sudo が壊れている
# ./create-debian.sh m68k-sid m68k sid
## なんか変
## ./create-debian.sh powerpc-sid powerpc sid
##  powerpc-utils : Depends: pmac-utils but it is not installable
# ./create-debian.sh ppc64-sid ppc64 sid
##  powerpc-utils : Depends: pmac-utils but it is not installable
# ./create-debian.sh riscv64-sid riscv64 sid
## git-man が入らない
# ./create-debian.sh sh4-sid sh4 sid
## 結構安定している?
# ./create-debian.sh sparc64-sid sparc64 sid
## aarch64 上では「E: Method gave invalid 400 URI Failure message: Could not switch saved set-user-ID」で apt が失敗する
#
# ppc64el bullseye, s390x bullseye
# systemd-networkd: Could not create manager: Protocol not supported
