load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} ${prefix}uEnv.txt
env import -t ${kernel_addr_r} ${filesize}
setenv ovsapply 'fdt addr ${fdt_addr_r}; fdt resize 8000; setexpr fdtovaddr ${fdt_addr_r} + 20000; for overlay in ${overlays}; do echo Applying DT overlay ${overlay}; load ${devtype} ${devnum}:${distro_bootpart} ${fdtovaddr} /boot/overlays/${overlay}.dtb && fdt apply ${fdtovaddr}; done'
setenv custom_linux_boot 'load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} /boot/vmlinuz-${kernelver}; if test -e ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} /boot/initrd.img-${kernelver}; then load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} /boot/initrd.img-${kernelver}; setenv initrd_arg ${ramdisk_addr_r}:${filesize}; else setenv initrd_arg '-'; fi; load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${fdtdir}${kernelver}/${fdtfile}; run ovsapply; booti ${kernel_addr_r} ${initrd_arg} ${fdt_addr_r}'
bootmenu ${menu_tmout}
