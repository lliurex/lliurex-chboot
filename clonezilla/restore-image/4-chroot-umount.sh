#!/bin/sh

for i in /sys/firmware/efi/efivars /run /sys /proc /dev/pts /dev /boot/efi  ; do sudo umount /mnt$i; done  

umount /mnt
