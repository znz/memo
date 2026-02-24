#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
[ -d .venv] || python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
exec python click.py "$@"
