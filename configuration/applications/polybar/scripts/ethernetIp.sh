#!/bin/bash

# Change this to match your Ethernet interface, such as eth0 or enpXsX.
interface="eth0"
color="#3a3a3f"

# Show the interface address only while the Ethernet link is active.
if ip link show "$interface" 2>/dev/null | grep -q "state UP"; then
  local_ip=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

  if [ -n "$local_ip" ]; then
    echo "%{F$color}ETH0 %{F-}$local_ip"
  else
    echo "%{F$color}ETH0 %{F-}0.0.0.0/0"
  fi
fi
