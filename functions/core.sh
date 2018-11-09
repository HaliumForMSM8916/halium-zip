#!/bin/bash
#
# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function convert_rootfs() {
	image_size=$1

	qemu-img create -f raw $IMAGE_DIR/rootfs.img $image_size
	sudo mkfs.ext4 -O ^metadata_csum -O ^64bit -F $IMAGE_DIR/rootfs.img
	sudo mount $IMAGE_DIR/rootfs.img $ROOTFS_DIR
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

function unmount() {
	sudo umount $ROOTFS_DIR
}

function flash() {
	adb push $IMAGE_DIR/rootfs.img /data/
	adb push $IMAGE_DIR/system.img /data/
}

function copy() {
	cp $IMAGE_DIR/rootfs.img $INSTALLDIR/
	cp $IMAGE_DIR/system.img $INSTALLDIR/
	cp $LOCATION/halium-boot.img $INSTALLDIR/
}

function prepare_zip () {
	cp -R $LOCATION/Installer/META-INF $INSTALLDIR/
	rpl "%date%" $DATE $INSTALLDIR/META-INF/com/google/android/updater-script
	rpl "%device%" $DEVICE $INSTALLDIR/META-INF/com/google/android/updater-script
}

function make_zip () {
	zip -r9 $FINAL_ZIP $INSTALLDIR/*
}
function clean() {
	# Delete created files from last install
	sudo rm $ROOTFS_DIR $IMAGE_DIR -rf
}

function clean_install() {
	sudo rm -rf $INSTALLDIR
}

function clean_device() {
	# Make sure the device is in a clean state
	adb shell sync
}
