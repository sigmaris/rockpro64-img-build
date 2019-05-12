apt-get update
apt-get install -y build-essential dbus dbus-user-session git make openssh-server vim
systemctl enable systemd-resolved
systemctl enable systemd-networkd

# Build latest mesa debian package:
apt-get install -y libclc-dev/experimental
apt-get build-dep -y mesa
mkdir -p /opt/build
pushd /opt/build
git clone --branch debian-experimental https://salsa.debian.org/xorg-team/lib/mesa.git
pushd mesa

popd
popd
