#!/bin/bash

# Change this to match your VPN interface.
interface="tun0"
color="#b392f0"

# Show the interface address only while the VPN tunnel is available.
if ip link show "$interface" 2>/dev/null | grep -q "state UNKNOWN"; then
  local_ip=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

  if [ -n "$local_ip" ]; then
    echo "%{F$color}TUN0 %{F-}$local_ip"
  else
    echo "%{F$color}TUN0 %{F-}0.0.0.0/0"
  fi
fi
