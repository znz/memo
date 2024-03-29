#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")"
if [[ ! -d "ruby-infra-recipe" ]]; then
    git clone --recursive https://github.com/ruby/ruby-infra-recipe
fi
cd ruby-infra-recipe

arch=$(uname -m)
os=$(uname -s | tr '[:upper:]' '[:lower:]')
sudo "/mnt/shared/mitamae-$arch-$os" local recipes/default.rb
