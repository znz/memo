#!/bin/bash
set -euxo pipefail
for v in $(rbenv install -l 2>/dev/null | grep -E '^[0-9]' | sort -r); do
    rbenv install -s -v $v
done
