#!/bin/bash
set -euxo pipefail
U=1000
if [[ -z "$(getent passwd chkbuild || :)" ]]; then
    adduser --disabled-login --no-create-home chkbuild
fi
install -o "$U" -g chkbuild -m 2755 -d /home/chkbuild
install -o "$U" -g chkbuild -m 2755 -d /home/chkbuild/build
install -o "$U" -g chkbuild -m 2755 -d /home/chkbuild/public_html
ln -snf /home/chkbuild "/home/$U/chkbuild/tmp"
