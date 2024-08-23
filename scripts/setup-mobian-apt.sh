#!/bin/sh

DEBIAN_SUITE=$1
SUITE=$2
CONTRIB=$3
NONFREE=$4

COMPONENTS="main"
[ "$CONTRIB" = "true" ] && COMPONENTS="$COMPONENTS contrib"
[ "$NONFREE" = "true" ] && COMPONENTS="$COMPONENTS non-free"

# Add debian-security for bullseye & bookworm; note that only the main component is supported
if [ "$DEBIAN_SUITE" = "bullseye" ] || [ "$DEBIAN_SUITE" = "bookworm" ]; then
    echo "deb http://security.debian.org/ $DEBIAN_SUITE-security $COMPONENTS" >> /etc/apt/sources.list
# Temporary hack: add unstable as a lower priority source to install packages removed from testing
else
    echo "deb http://deb.debian.org/debian unstable $COMPONENTS" >> /etc/apt/sources.list.d/unstable.list
    echo "deb http://deb.debian.org/debian experimental $COMPONENTS" >> /etc/apt/sources.list.d/experimental.list

    cat > /etc/apt/preferences.d/10-unstable-priority << EOF
Package: *
Pin: release a=unstable
Pin-Priority: 200
EOF

    cat > /etc/apt/preferences.d/20-experimental-priority << EOF
Package: *
Pin: release a=experimental
Pin-Priority: 250
EOF
fi

# Set the proper suite in our sources.list
sed -i "s/@@SUITE@@/${SUITE}/" /etc/apt/sources.list.d/mobian.list

# Setup repo priorities so mobian comes first
cat > /etc/apt/preferences.d/00-mobian-priority << EOF
Package: *
Pin: release o=Mobian
Pin-Priority: 700
EOF
