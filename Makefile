
.PHONY: all
all: 

.PHONY: clean
clean:
	rm debian-buster-arm64-rootfs.tar.xz

debian-buster-arm64-rootfs.tar.xz:
	TEMP=$$(mktemp -d $$(readlink -f out)/build.XXXXX) ; \
	pushd $$TEMP ; \
	qemu-debootstrap --arch=arm64 --components=main,contrib,non-free buster rootfs ; \
	tar --create --auto-compress --file ../../$@ rootfs ; \
	popd ; \
	popd ; \
	rm -rf $$TEMP
