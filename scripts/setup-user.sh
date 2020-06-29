#!/bin/sh -e
adduser --gecos "Rock User" \
  --disabled-password \
  --shell /bin/bash \
  rock

usermod -a -G adm,dialout,cdrom,sudo,audio,video,render,plugdev,games,users,input rock

# Ubuntu doesn't have the netdev group
if getent group netdev >/dev/null
then
	usermod -a -G netdev rock
fi

# Set initial password for rock
echo "rock:rock.64" | chpasswd

# Expire password so it requires changing immediately after login
passwd -e rock
