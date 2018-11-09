## Alternative Halium installer script

The difference to the official script from the halium-scripts repository is that this script will prepare the rootfs on your host system instead of on the device. Also this script will write it to a zip file wich can be installed on a Recovery like TWRP. This will make you independent of problems like old TWRP images, no busybox or not-working busyboxes on some devices.


### Dependencies

* qemu-user-static
* qemu-system-arm
* e2fsprogs
* simg2img
* rpl

### Usage:

Install a halium rootfs and systemimage:
`halium-install -p <mode (halium, pm, none)> <rootfs.tar.gz> <system.img> <device codename>`

### Standalone version (Untested)
If you want to use this shell script independently of this folder, create a standalone script of it by executing `bash utils/standalone.sh`. You will find the executable in bin/halium-install-standalone.sh.
