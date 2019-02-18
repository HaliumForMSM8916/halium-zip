#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs_to_img() {
	image_size=$1

	qemu-img create -f raw $IMAGE_DIR/rootfs.img $image_size
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F $IMAGE_DIR/rootfs.img
	sudo mount $IMAGE_DIR/rootfs.img $ROOTFS_DIR
	sudo tar -xf $ROOTFS_TAR -C $ROOTFS_DIR
}

function convert_rootfs_to_dir() {
	sudo tar -xf $ROOTFS_TAR -C $ROOTFS_DIR
}

function convert_androidimage() {
	if file $AND_IMAGE | grep "ext[2-4] filesystem"; then
		cp $AND_IMAGE $IMAGE_DIR/system.img
	else
		simg2img $AND_IMAGE $IMAGE_DIR/system.img
	fi
}

function shrink_images() {
	[ -f $IMAGE_DIR/system.img ] && sudo e2fsck -fy $IMAGE_DIR/system.img >/dev/null
	[ -f $IMAGE_DIR/system.img ] && sudo resize2fs -p -M $IMAGE_DIR/system.img
}

function inject_androidimage() {
	sudo mv $IMAGE_DIR/system.img $ROOTFS_DIR
}

function unmount() {
	sudo umount $ROOTFS_DIR
}

function flash_img() {
	adb push $IMAGE_DIR/rootfs.img /data/
	adb push $IMAGE_DIR/system.img /data/
}

function copy_img() {
	cp $IMAGE_DIR/rootfs.img $INSTALLDIR/
	cp $IMAGE_DIR/system.img $INSTALLDIR/
	if [ -f halium-boot.img ]; then
		cp halium-boot.img $INSTALLDIR/boot.img
	elif [ -f hybris-boot.img ]; then
		cp hybris-boot.img $INSTALLDIR/boot.img
	else
		echo "No halium/hybris boot image found"
		exit 1
	fi
}

function copy_dir() {
	mkdir -p $ROOTFS_DIR/halium-rootfs/
	mv $ROOTFS_DIR/* $ROOTFS_DIR/halium-rootfs/
	tar -cf $ROOTFS_DIR/halium-rootfs $INSTALLDIR/halium-rootfs.tar
	if [ -f halium-boot.img ]; then
		cp halium-boot.img $INSTALLDIR/boot.img
	elif [ -f hybris-boot.img ]; then
		cp hybris-boot.img $INSTALLDIR/boot.img
	else
		echo "No halium/hybris boot image found"
		exit 1
	fi
}

function prepare_install_script() {
	mkdir -p $INSTALLDIR/META-INF/com/google/android
	case "$1" in
	halium)
		cat $LOCATION/Installer/headers/HAL >> $INSTALLDIR/META-INF/com/google/android/update-binary
		;;
	debian-pm | debian-pm-caf | pm | neon)
		cat $LOCATION/Installer/headers/PM >> $INSTALLDIR/META-INF/com/google/android/update-binary
		;;
	ut)
		cat $LOCATION/Installer/headers/UT >> $INSTALLDIR/META-INF/com/google/android/update-binary
		;;
	esac

	cat $LOCATION/Installer/headers/common >> $INSTALLDIR/META-INF/com/google/android/update-binary

	case "$2" in
	img)
		cat $LOCATION/Installer/install_img >> $INSTALLDIR/META-INF/com/google/android/update-binary
		;;
	dir)
		cat $LOCATION/Installer/install_dir >> $INSTALLDIR/META-INF/com/google/android/update-binary
	esac
	cp $LOCATION/Installer/updater-script $INSTALLDIR/META-INF/com/google/android/updater-script
	rpl "%date%" $DATE $INSTALLDIR/META-INF/com/google/android/update-binary
	rpl "%device%" $DEVICE $INSTALLDIR/META-INF/com/google/android/update-binar
}

function make_zip () {
	cd $INSTALLDIR
	zip -r9 ../$FINAL_ZIP *
}

function flash_dir() {
	adb push $ROOTFS_DIR/* /data/halium-rootfs/
}

function clean() {
	# Delete created files from last install
	sudo rm $ROOTFS_DIR $IMAGE_DIR -rf
	sudo rm -rf $INSTALLDIR
}

function clean_device() {
	# Make sure the device is in a clean state
	adb shell sync
}
