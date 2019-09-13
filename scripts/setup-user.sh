#!/bin/sh
adduser --gecos "Rock User" \
  --disabled-password \
  --shell /bin/bash \
  rock

adduser rock sudo

echo "rock:rock.64" | chpasswd
