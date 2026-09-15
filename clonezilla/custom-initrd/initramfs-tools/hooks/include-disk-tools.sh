#!/bin/sh
PREREQ=""
prereqs() {
    echo "$PREREQ"
}

case $1 in
prereqs)
    prereqs
    exit 0
    ;;
esac

. /usr/share/initramfs-tools/hook-functions

# Copy required disk utilities to the initramfs

for b in /usr/sbin/partclone.restore /usr/sbin/resize2fs /usr/sbin/e2fsck /usr/bin/lsblk ; do
	copy_exec $b
done


