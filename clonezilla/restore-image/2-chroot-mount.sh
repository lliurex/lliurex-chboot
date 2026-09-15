#!/bin/sh
DEST_PART=/dev/sda5
EFI_PART=/dev/sda1

mount $DEST_PART /mnt
mount $EFI_PART /mnt/boot/efi 

# test if efivarfs is already mounted
EFIVARS_DIR="/sys/firmware/efi/efivars"
ls -1 $EFIVARS_DIR 2>/dev/null |grep -q "." || mount -t efivarfs none $EFIVARS_DIR

for d in /dev /dev/pts /proc /sys /run $EFIVARS_DIR ; do mount --bind $d /mnt$d; done  

# copy etc files
SOURCE_DIR="./etc"

ls -1 "$SOURCE_DIR" |while read f; do cp "$SOURCE_DIR/$f" "/mnt/$SOURCE_DIR/" ; done

