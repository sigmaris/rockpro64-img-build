#!/bin/bash
qemu-system-x86_64 \
	-machine accel=hvf \
	-cpu host \
	-smp $(($(nproc) / 2)) \
	-hda debian.qcow \
	-netdev user,id=net0,net=10.0.2.0/24,hostname=rp64builder,domainname=localdomain,hostfwd=tcp:127.0.0.1:10022-:22 \
	-device e1000,netdev=net0,mac=52:54:98:76:54:32 \
	-m 4096 \
	-nographic \
	-serial mon:telnet::10023,server,nowait &

function remote_command {
	ssh -A -p 10022 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@127.0.0.1 "$@"
}

for attempt in $(seq 20)
do
	echo "Trying checkout of code on build VM..."
	remote_command "if test -d /rockpro64-img-build ; then cd /rockpro64-img-build ; git fetch origin ; else cd / ; git clone $(whoami)@10.0.2.2:$(realpath ..) rockpro64-img-build ; cd rockpro64-img-build ; git remote add github git@github.com:sigmaris/rockpro64-img-build.git ; fi"
	if [ $? -eq 0 ]
	then
		break
	else
		sleep 10
	fi
done

if [ $? -ne 0 ]
then
	echo "error: VM didn't come up in time."
	exit 1
fi

remote_command "cd / ; make all"
