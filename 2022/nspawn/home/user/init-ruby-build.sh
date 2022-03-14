#!/bin/bash
set -euxo pipefail
sudo apt-get update
# ruby-build wiki
sudo apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
# ruby-build deb Recommends
sudo apt-get install -y libsqlite3-dev libssl-dev libxml2-dev libxslt-dev

sudo apt-get install -y git
sudo apt-get install -y wget curl aria2
sudo apt-get install -y ruby
sudo apt-get install -y ccache

case $(< /etc/debian_version) in
    10.*)
	# OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=error: certificate verify failed (unable to get local issuer certificate): https://raw.githubusercontent.com/gcc-mirror/gcc/master/config.guess
	# になるので https://packages.debian.org/bullseye/ca-certificates を入れる
	if [ ! -f ca-certificates_20210119_all.deb ]; then
	    wget https://deb.debian.org/debian/pool/main/c/ca-certificates/ca-certificates_20210119_all.deb
	    sudo dpkg -i ca-certificates_20210119_all.deb
	fi
	;;
esac

sudo etckeeper vcs gc

if [ ! -d ~/.rbenv ]; then
    git clone https://github.com/rbenv/rbenv ~/.rbenv --depth=1
fi

if ! grep -q rbenv ~/.bashrc; then
  {
    echo
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
    echo 'eval "$(rbenv init -)"'
    echo 'export CC="ccache gcc" CXX="ccache g++" MJIT_CC=gcc'
  } >> ~/.bashrc
fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export CC="ccache gcc" CXX="ccache g++" MJIT_CC=gcc

if [ ! -d "$(rbenv root)"/plugins/ruby-build ]; then
    git clone https://github.com/rbenv/ruby-build "$(rbenv root)"/plugins/ruby-build --depth=1
fi
if [ ! -d ~/ruby ]; then
    git clone https://github.com/ruby/ruby ~/ruby --depth=1
else
    cd ~/ruby
    git pull
fi
mkdir -p ~/ruby/build
cd ~/ruby/build
../autogen.sh
../configure --prefix="$(rbenv root)"/versions/master --with-baseruby=/usr/bin/ruby --disable-install-doc
make -j$(nproc)
make install -j$(nproc)
make check -j$(nproc)
