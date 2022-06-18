#!/bin/bash
set -euxo pipefail

sudo loginctl enable-linger $USER
mkdir -p ~/.config/systemd/user
