#!/bin/sh
#
die(){
	echo "Usage: $0 IMAGE_FILE|IMAGE_DIR TARGET_PART EFI_PART [GRUB_DEVICE]" >&2
	exit 1
}

[ $# -ge 3 ] || die
IMAGE_FILE="$1"
# TODO: manage directory with fragmented image files

DEST_PART="$2"
EFI_PART="$1"
GRUB_DEVICE="$4"

if [ -z "$GRUB_DEVICE" ] ; then
	# get 'parent' from DEST_PART
	GRUB_DEVICE="$(lsblk -ndo pkname "$DEST_PART")"
fi

# preserve root partition UUID
DEST_UUID="$(lsblk -plo NAME,UUID |sed -ne "\%^\s*$DEST_PART%{s%$DEST_PART%%;s%\s*%%;p}")"

CAT_CMD="zstdcat"
#TODO: Determine compression type and use apropiate tool

$CAT_CMD "$IMAGE_FILE" |partclone.restore -I -C -d -s - -o $DEST_PART

#clean and resize
e2fsck -f $DEST_PART
resize2fs $DEST_PART

#restore UUID
tune2fs -U "$DEST_UUID" "$DEST_PART"

#mount 'chroot'

mount $DEST_PART /mnt
mount $EFI_PART /mnt/boot/efi 

EFIVARS_DIR="/sys/firmware/efi/efivars"

# test if efivarfs is already mounted
ls -1 $EFIVARS_DIR 2>/dev/null |grep -q "." || mount -t efivarfs none $EFIVARS_DIR

# do bind mounts
for d in /dev /dev/pts /proc /sys /run $EFIVARS_DIR ; do mount --bind $d /mnt$d; done  

# copy etc files
SOURCE_DIR="./etc"

ls -1 "$SOURCE_DIR" |while read f; do cp "$SOURCE_DIR/$f" "/mnt/$SOURCE_DIR/" ; done

# install and update grub in chroot
chroot /mnt grub-install $DEST_DISK
chroot /mnt update-grub

# umount bind dirs

for d in /sys/firmware/efi/efivars /run /sys /proc /dev/pts /dev /boot/efi  ; do sudo umount /mnt$d; done  

umount /mnt

echo "Done!"

