#!/bin/bash

# update wsl ip
hosts="/etc/hosts"
gateway_ip=$(ip route show | grep -i 'default via'| awk '{print $3 }')
hostname="host.docker.internal"

if cat "$hosts" | grep -qF "$hostname"; then
  sudo sed -i "/$hostname/ s/.*/$gateway_ip\t$hostname/g" "$hosts"
else
  sudo tee -a "$hosts" > /dev/null <<EOT

$gateway_ip	$hostname
EOT
fi
