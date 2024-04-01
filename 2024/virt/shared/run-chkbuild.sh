#!/bin/bash
exec sudo systemd-run \
     --uid=chkbuild --gid=chkbuild \
     -E RUBYCI_NICKNAME=debian-riscv64 \
     -p WorkingDirectory=/home/chkbuild/chkbuild \
     ruby start-rubyci
#     bash -c 'git pull -q; exec ruby start-rubyci'
