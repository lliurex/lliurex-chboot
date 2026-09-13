#!/bin/sh
DEST_PART=/dev/sda5
EFI_PART=/dev/sda1

mount $DEST_PART /mnt
mount $EFI_PART /mnt/boot/efi 

for i in /dev /dev/pts /proc /sys /run /sys/firmware/efi/efivars ; do sudo mount -B $i /mnt$i; done  

# copy etc files
SOURCE_DIR="./etc"

ls -1 "$SOURCE_DIR" |while read f; do cp "$SOURCE_DIR/$f" "/mnt/$SOURCE_DIR/" ; done

