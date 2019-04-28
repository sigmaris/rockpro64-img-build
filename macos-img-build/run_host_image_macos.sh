#!/bin/bash
exec qemu-system-x86_64 \
	-machine accel=hvf \
	-cpu host \
	-hda debian.qcow \
	-netdev user,id=net0,net=10.0.2.0/24,hostname=rp64builder,domainname=localdomain,hostfwd=tcp:127.0.0.1:2200-:22 \
	-device e1000,netdev=net0,mac=52:54:98:76:54:32 \
	-m 512 \
	-nographic
