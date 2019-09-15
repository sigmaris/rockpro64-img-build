#!/bin/sh

# Set "Platform required" attributes on bootloader partitions
sgdisk --attributes=1:set:0 --attributes=2:set:0 --attributes=3:set:0 --attributes=4:set:0 --attributes=5:set:0 --attributes=6:set:0 "$1"

# Set the type of the bootloader partitions to "Linux reserved"
sgdisk --typecode=1:8301 --typecode=2:8301 --typecode=3:8301 --typecode=4:8301 --typecode=5:8301 "$1"
