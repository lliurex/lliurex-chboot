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

for b in /usr/sbin/partclone.restore /usr/sbin/partclone.extfs /usr/sbin/partclone.xfs /usr/sbin/partclone.reiser4 /usr/sbin/partclone.btrfs ; do
	copy_exec $b
done


