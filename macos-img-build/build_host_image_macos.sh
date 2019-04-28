#!/bin/bash -e

if [ "$(uname -s)" != "Darwin" ]
then
	echo "This script is for building a Debian x86_64 image to use on MacOS"
	exit 1
fi

TEMP="$(mktemp -d build.XXXXX)"
cp preseed.cfg $TEMP
pushd $TEMP

AUTHORIZED_KEYS="$(ssh-add -L)"
if [ -n "$AUTHORIZED_KEYS" ]
then
	echo "Pre-populating authorized_keys for image"
	echo "$AUTHORIZED_KEYS" > authorized_keys
fi

ROOT_PASSWORD="$(openssl rand -base64 18)"
echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "==> Randomised root password is: $ROOT_PASSWORD <=="
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
CRYPTED_PASSWORD="$(openssl passwd -1 -salt xyz $ROOT_PASSWORD)"

echo "Running simple webserver on port 4321 for host files..."
PYTHON_PID=$(sh -c 'echo $$ ; exec >/dev/null 2>&1 ; exec python -m SimpleHTTPServer 4321' &)

echo "Running netcat to capture syslogs..."
NC_PID=$(sh -c 'echo $$ ; exec > ../installer.log 2>&1 ; exec nc -ul 10514' &)

echo "Downloading Debian Testing x86_64 netboot installer..."
curl --location --output netboot.tar.gz https://deb.debian.org/debian/dists/buster/main/installer-amd64/current/images/netboot/netboot.tar.gz
mkdir -p tftpserver
pushd tftpserver
tar xzvf ../netboot.tar.gz

echo "Customising network boot parameters..."
cat > debian-installer/amd64/pxelinux.cfg/default <<EOF
serial 0
prompt 0
default autoinst
label autoinst
kernel debian-installer/amd64/linux
append initrd=debian-installer/amd64/initrd.gz auto=true priority=critical passwd/root-password-crypted=$CRYPTED_PASSWORD DEBIAN_FRONTEND=text url=http://10.0.2.2:4321/preseed.cfg log_host=10.0.2.2 log_port=10514 --- console=ttyS0
EOF
popd

echo "Creating disk image for Debian Testing x86_64..."
qemu-img create -f qcow2 ../debian.qcow 4G

echo "Running Debian Installer..."
qemu-system-x86_64 \
	-machine accel=hvf \
	-cpu host \
	-hda ../debian.qcow \
	-netdev user,id=net0,net=10.0.2.0/24,hostname=rp64builder,domainname=localdomain,tftp=tftpserver,bootfile=/pxelinux.0 \
	-device e1000,netdev=net0,mac=52:54:98:76:54:32 \
	-boot once=n \
	-m 512 \
	-nographic

echo "Removing temporary directory $TEMP ..."
popd
rm -rf $TEMP

echo "Cleaning up processes..."
kill $PYTHON_PID
kill $NC_PID
