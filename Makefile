ROOTFS_RELEASE ?= $(shell date -u +%Y%m%dT%H%M%S)
FILESYSTEM_FILES := $(shell find filesystem -type f)
BUSTER_ROOTFS_FILES := $(patsubst filesystem/%,buster-rootfs/%,$(FILESYSTEM_FILES))

.PHONY: all
all: 

.PHONY: clean
clean:
	rm -f debian-buster-arm64-rootfs.tar.xz
	rm -rf buster-rootfs

info:
	@echo "filesystem files:"
	@echo "$(FILESYSTEM_FILES)"
	@echo "buster-rootfs files:"
	@echo "$(BUSTER_ROOTFS_FILES)"

debian-buster-arm64-rootfs.tar.xz:
	TEMPDIR="$$(mktemp -d build.XXXXX)" ; \
	cd "$${TEMPDIR}" ; \
	qemu-debootstrap --arch=arm64 --components=main,contrib,non-free buster rootfs ; \
	tar --create --auto-compress --file ../$@ rootfs ; \
	cd .. ; \
	rm -rf "$${TEMPDIR}"

.PHONY: rootfs-release
rootfs-release: debian-buster-arm64-rootfs.tar.xz
	test -n '$(ROOTFS_RELEASE)'
	test -n "$$GH_USERNAME"
	test -n "$$GH_ACCESS_TOKEN"
	git config credential.helper "/bin/sh $$(pwd)/github-credential-helper.sh"
	git tag 'buster-rootfs-$(ROOTFS_RELEASE)'
	git push github 'buster-rootfs-$(ROOTFS_RELEASE)'
	@API_JSON=$$(printf '{"tag_name":"buster-rootfs-%s","target_commitish":"%s","name":"buster-rootfs-%s","body":"Buster rootfs.tar.xz %s","draft":false,"prerelease":false}' '$(ROOTFS_RELEASE)' "$$(git rev-parse HEAD)" '$(ROOTFS_RELEASE)' '$(ROOTFS_RELEASE)' ) ; \
		curl --data "$$API_JSON" \
		--output gh_response.json \
		-H "Authorization: token $$GH_ACCESS_TOKEN" \
		"https://api.github.com/repos/$${GH_USERNAME}/rockpro64-img-build/releases"
	@curl --data-binary @debian-buster-arm64-rootfs.tar.xz \
		-H "Authorization: token $$GH_ACCESS_TOKEN" \
		-H "Content-Type: application/tar+xz" \
		"$$(jq -r .upload_url gh_response.json | sed 's/{?.*}$$/?name=debian-buster-arm64-rootfs.tar.xz/')"

buster-rootfs: debian-buster-arm64-rootfs.tar.xz
	mkdir $@
	cd $@ && tar --extract --auto-compress --strip-components=1 --file ../$<

buster-rootfs/%: filesystem/% | buster-rootfs
	cp "$<" "$@"

.PHONY: buster-packages
buster-packages: $(BUSTER_ROOTFS_FILES)
	cp installtarget.sh buster-rootfs
	# We assume here that /usr/bin/qemu-aarch64-static was packaged in the rootfs tarball from qemu-debootstrap
	systemd-nspawn -D buster-rootfs bin/bash -e -c 'source /installtarget.sh ; rm /installtarget.sh'
