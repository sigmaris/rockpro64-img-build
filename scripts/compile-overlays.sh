#!/bin/bash

shopt -s nullglob

OVDIR="$(realpath "${ROOTDIR}/boot/overlays")"
for overlay in "$OVDIR"/*.dts
do
	echo "DTC $overlay"
	dtc -@ -H epapr -I dts -O dtb "${overlay}" > "${overlay%.dts}.dtb"
done
