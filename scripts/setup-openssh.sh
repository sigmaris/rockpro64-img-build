#!/bin/sh

# Remove host keys and regenerate them on next boot
rm -f /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub
systemctl enable ssh-keygen.service
