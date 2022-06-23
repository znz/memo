#!/bin/bash
set -euxo pipefail
# Run on host:
# ./autogen.sh -i

rm -rf ~/ruby/build
mkdir -p ~/ruby/build
cd ~/ruby/build
/Users/*/s/github.com/ruby/ruby/configure cppflags='-DUSE_RVARGC -DRUBY_DEBUG -DVM_CHECK_MODE=1 -DTRANSIENT_HEAP_CHECK_MODE -DRGENGC_CHECK_MODE -DENC_DEBUG -DUSE_RUBY_DEBUG_LOG=1' CC='ccache gcc' MJIT_CC=gcc CXX='ccache g++' --prefix=$(rbenv root)/versions/master --with-baseruby=/usr/bin/ruby --disable-install-doc
make -j$(nproc)
make install INSTRUBY_OPTS="--exclude bundled-gems"
rbenv local master
