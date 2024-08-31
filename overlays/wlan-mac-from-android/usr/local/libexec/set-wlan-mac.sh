#!/bin/bash
set -euo pipefail

wlan_mac="empty"
if [[ -b /dev/disk/by-partlabel/persist ]]
then
  mountpoint="$(mktemp -d)"
  mount -o ro /dev/disk/by-partlabel/persist "$mountpoint"
  set +e
  wlan_mac="$(grep -Po '(?<=Intf0MacAddress=)[A-Fa-f0-9]{12}' ${mountpoint}/wlan_mac.bin)"
  set -e
  umount "$mountpoint"
  rmdir "$mountpoint"
fi

if [[ "${#wlan_mac}" != "12" ]]
then
  echo "Could not read wlan0 MAC address from Android partition, generating random one..."
  wlan_mac="$(printf '02%02X%02X%02X%02X%02X' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])"
fi

cat > /etc/udev/rules.d/10-wlan0-persistent-mac-address.rules <<EOT
ACTION=="add", SUBSYSTEM=="net", INTERFACE=="wlan0", PROGRAM="/usr/bin/ip link set %k address ${wlan_mac:0:2}:${wlan_mac:2:2}:${wlan_mac:4:2}:${wlan_mac:6:2}:${wlan_mac:8:2}:${wlan_mac:10:2}"
EOT
