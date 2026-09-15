#!/bin/sh
DEST_DISK=/dev/sda

chroot /mnt grub-install $DEST_DISK
chroot /mnt update-grub
