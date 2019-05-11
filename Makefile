ROOTFS_RELEASE ?= $(shell date -u +%Y%m%dT%H%M%S)

.PHONY: all
all: 

.PHONY: clean
clean:
	rm -f debian-buster-arm64-rootfs.tar.xz

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
	@API_JSON=$$(printf '{"tag_name":"buster-rootfs-%s","target_commitish":"master","name":"buster-rootfs-%s","body":"Buster rootfs.tar.xz %s","draft":false,"prerelease":false}' '$(ROOTFS_RELEASE)' '$(ROOTFS_RELEASE)' '$(ROOTFS_RELEASE)' ) ; \
		curl --data "$$API_JSON" \
		--output gh_response.json \
		-H "Authorization: token $$GH_ACCESS_TOKEN" \
		"https://api.github.com/repos/$${GH_USERNAME}/rockpro64-img-build/releases"
	@curl --data-binary @debian-buster-arm64-rootfs.tar.xz \
		-H "Authorization: token $$GH_ACCESS_TOKEN" \
		-H "Content-Type: application/tar+xz" \
		"$$(jq .upload_url gh_response.json)"
