#!/bin/sh
adduser --gecos "Rock User" \
  --disabled-password \
  --shell /bin/bash \
  rock

usermod -a -G adm,dialout,cdrom,sudo,audio,video,render,plugdev,games,users,input,netdev rock

echo "rock:rock.64" | chpasswd
passwd -e rock
