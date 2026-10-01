#!/bin/sh
# update vars before install
CHB_MNT_POINT="/mnt"
CHB_BOOT="$CHB_MNT_POINT/boot"
CHB_GRUB="/dev/sda"

mkdir "$CHB_BOOT"

grub-install "$CHB_GRUB" --efi-directory=/boot/efi --boot-directory="$CHB_BOOT"
