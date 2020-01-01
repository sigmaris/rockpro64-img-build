#!/bin/bash
# Script from https://github.com/ayufan-rock64/linux-package,
# modified to find partition number and leave a marker file in /var/local

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

dev=$(findmnt / -n -o SOURCE)

case $dev in
	/dev/mmcblk*p*)
		DISK="$(echo "$dev" | sed -e 's#^\(/dev/mmcblk[[:digit:]]\+\)p[[:digit:]]\+$#\1#')"
		PARTNUM="$(echo "$dev" | sed -e 's#^/dev/mmcblk[[:digit:]]\+p\([[:digit:]]\+\)$#\1#')"
		NAME="sd/emmc"
		;;

	/dev/sd*)
		DISK="$(echo "$dev" | sed -e 's#^\(/dev/sd[[:alpha:]]\+\)[[:digit:]]\+$#\1#')"
		PARTNUM="$(echo "$dev" | sed -e 's#^/dev/sd[[:alpha:]]\+\([[:digit:]]\+\)$#\1#')"
		NAME="hdd/ssd"
		;;

	/dev/nvme*n*)
		DISK="$(echo "$dev" | sed -e 's#^\(/dev/nvme[[:digit:]]\+n[[:digit:]]\+\)p[[:digit:]]\+$#\1#')"
		PARTNUM="$(echo "$dev" | sed -e 's#^/dev/nvme[[:digit:]]\+n[[:digit:]]\+p\([[:digit:]]\+\)$#\1#')"
		NAME="nvme"
		;;

	*)
		echo "Unknown disk for $dev"
		exit 1
		;;
esac

# Sanity check
if [[ ! -b "$DISK" ]] || [[ ! "$PARTNUM" -ge 0 ]]; then
	echo "Couldn't recognize $dev as a partition"
	exit 1
fi

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
