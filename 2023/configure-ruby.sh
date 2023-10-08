#!/bin/bash
set -euxo pipefail
mkdir -p $HOME/build/ruby
cd $HOME/build/ruby

if [ -x /usr/bin/ruby ]; then
    BASERUBY=/usr/bin/ruby
elif [ -x /snap/bin/ruby ]; then
    BASERUBY=/snap/bin/ruby
else
    BASERUBY=noruby
fi

/Users/*/s/github.com/ruby/ruby/configure \
    'cppflags=-DUSE_RVARGC -DRUBY_DEBUG -DVM_CHECK_MODE=1 -DTRANSIENT_HEAP_CHECK_MODE -DRGENGC_CHECK_MODE -DENC_DEBUG -DUSE_RUBY_DEBUG_LOG=1' \
    'CC=ccache gcc' 'MJIT_CC=gcc' 'CXX=ccache g++' \
    "--prefix=$(rbenv root)/versions/master" \
    "--with-baseruby=${BASERUBY}" \
    '--disable-install-doc' \
    '--enable-yjit=dev_nodebug'
