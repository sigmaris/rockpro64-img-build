#!/bin/sh

# Network management
systemctl enable systemd-networkd
# DNS resolving
systemctl enable systemd-resolved
# NTP client
systemctl enable systemd-timesyncd
