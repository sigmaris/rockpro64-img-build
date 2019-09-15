#!/bin/bash
# Script from https://github.com/ayufan-rock64/linux-package,
# modified to find partition number and leave a marker file in /var/local

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

dev=$(findmnt / -n -o SOURCE)

case $dev in
	/dev/mmcblk*)
		DISK=${dev:0:12}
		PARTNUM=${dev:13}
		NAME="sd/emmc"
		;;

	/dev/sd*)
		DISK=${dev:0:8}
		PARTNUM=${dev:8}
		NAME="hdd/ssd"
		;;

	*)
		echo "Unknown disk for $dev"
		exit 1
		;;
esac

echo "Resizing $DISK partition $PARTNUM ($NAME -- $dev)..."

set -xe

# move GPT alternate header to end of disk
sgdisk -e "$DISK"

# resize partition PARTNUM to as much as possible
echo ",+,,," | sfdisk "${DISK}" -N${PARTNUM} --force

# re-read partition table
partprobe "$DISK"

# online resize filesystem
resize2fs "$dev"

# Mark that the root filesystem was resized successfully
touch /var/local/.rootfs-resized
