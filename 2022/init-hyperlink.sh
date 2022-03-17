#!/bin/bash
set -euxo pipefail

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cd $HOME
git clone https://github.com/untitaker/hyperlink
cd hyperlink/
cargo build --release
