#!/bin/bash
set -euxo pipefail
resolvectl mdns
sed -i -e 's/^#\?MulticastDNS=.*/MulticastDNS=yes/' /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service
network_d=$(echo /run/systemd/network/10-netplan-e*.network | sed -e 's,^/run,/etc,' -e 's,$,.d,')
mkdir -p "$network_d"
cat >"$network_d/mdns.conf" <<'EOF'
[Network]
MulticastDNS=yes
EOF
systemctl reload systemd-networkd.service
resolvectl mdns
