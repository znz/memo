#!/bin/bash
set -euxo pipefail

trap "sudo etckeeper vcs gc" EXIT
sudo apt install -y ccache

# anyenv
if [ ! -d ~/.anyenv ]; then
    git clone https://github.com/anyenv/anyenv ~/.anyenv
fi
if ! grep -q anyenv ~/.bashrc; then
    {
	echo
	echo 'export PATH="$HOME/.anyenv/bin:$PATH"'
	echo 'eval "$(anyenv init -)"'
	echo 'export CC="ccache gcc" CXX="ccache g++" MJIT_CC=gcc'
    } >> ~/.bashrc
fi
export PATH="$HOME/.anyenv/bin:$PATH"
set +x; eval "$(anyenv init -)"; set -x
if [ ! -d ~/.config/anyenv/anyenv-install ]; then
    anyenv install --force-init
fi
if [ ! -d "$(anyenv root)/plugins/anyenv-update" ]; then
    git clone https://github.com/znz/anyenv-update "$(anyenv root)/plugins/anyenv-update"
fi
if [ ! -d "$(anyenv root)/plugins/anyenv-git" ]; then
    git clone https://github.com/znz/anyenv-git "$(anyenv root)/plugins/anyenv-git"
fi
for e in rbenv nodenv; do
    if [ ! -d "$(anyenv root)/envs/$e" ]; then
	anyenv install "$e"
    fi
done
unset e
set +x; eval "$(anyenv init -)"; set -x

# node
node_latest=$(nodenv install -l | grep -E '^[0-9]' | sort -Vr | head -n1)
if ! [[ $(nodenv versions) =~ $node_latest ]]; then
    nodenv install $node_latest
    nodenv global $node_latest
    corepack enable
fi
unset node_latest
set +x; eval "$(anyenv init -)"; set -x

# rbenv
if [ ! -d "$(rbenv root)/plugins/rbenv-plug" ]; then
    git clone https://github.com/znz/rbenv-plug "$(rbenv root)/plugins/rbenv-plug"
fi
for p in rbenv-aliases rbenv-each; do
    if [ ! -d "$(rbenv root)/plugins/$p" ]; then
	rbenv plug "$p"
    fi
done
unset p

# ruby-build wiki
sudo apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
# ruby-build deb Recommends
sudo apt-get install -y libsqlite3-dev libssl-dev libxml2-dev libxslt-dev
# more dependencies
sudo apt-get install -y ruby
sudo apt-get install -y wget curl aria2

# ruby master
mkdir -p ~/ruby/build
if [ ! -f "$(rbenv root)/versions/master/bin/ruby" ]; then
    (
	cd ~/ruby/build
	/Users/*/s/github.com/ruby/ruby/configure cppflags='-DUSE_RVARGC -DRUBY_DEBUG -DVM_CHECK_MODE=1 -DTRANSIENT_HEAP_CHECK_MODE -DRGENGC_CHECK_MODE -DENC_DEBUG -DUSE_RUBY_DEBUG_LOG=1' CC='ccache gcc' MJIT_CC=gcc CXX='ccache g++' --prefix=$(rbenv root)/versions/master --with-baseruby=/usr/bin/ruby --disable-install-doc
	make all install -j$(nproc)
	rbenv global master
    )
fi

# ruby released
for v in $(rbenv install -l 2>/dev/null | grep -E '^[0-9]' | sort -r); do
    rbenv install -s -v $v
done
set +x; eval "$(anyenv init -)"; set -x
