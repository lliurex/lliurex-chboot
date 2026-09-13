#!/bin/sh
DEST_DISK=/dev/sda
DEST_PART=/dev/sda5


chroot /mnt  $DEST_PART
chroot /mnt grub-install $DEST_DISK
chroot /mnt update-grub
