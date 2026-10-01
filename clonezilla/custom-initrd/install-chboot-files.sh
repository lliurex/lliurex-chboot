#!/bin/sh
MOUNT_POINT="/mnt"
CHBOOT_DIRNAME="chboot"
BOOT_DIR="$MOUNT_POINT/boot"
CHBOOT_DIR="$MOUNT_POINT/$CHBOOT_DIRNAME"

echo "CHBOOT mountpoint: $MOUNT_POINT"
echo "CHBOOT image and files directory: $CHBOOT_DIR"
echo "CHBOOT boot directory (for grub): $BOOT_DIR"
echo ""
echo "Press ENTER to install files"
read a

get_disk_id(){
	MOUNT_POINT="$1"
	ID_TYPE="$2"
	lsblk -nplo MOUNTPOINT,$ID_TYPE |sed -ne "\%$MOUNT_POINT\s%{s%^.*\s%%;p}"
}

get_uuid(){
	MOUNT_POINT="$1"
	ID_TYPE="UUID"
	get_disk_id "$MOUNT_POINT" "$ID_TYPE"
}

get_partuuid(){
	MOUNT_POINT="$1"
	ID_TYPE="PARTUUID"
	get_disk_id "$MOUNT_POINT" "$ID_TYPE"
}

gen_grub_cfg(){
	pkgdatadir=/usr/lib/grub
	GRUB_THEME=""
	. /etc/grub.d/00_header

	cat <<EOF
set timeout=10
search --no-floppy --fs-uuid --set=root ${CHBOOT_UUID}

menuentry 'CHBOOT: ${CHBOOT_TITLE} (${KERNEL_VERSION})' --class lliurex --class gnu-linux --class gnu --class os \$menuentry_id_option 'gnulinux-${KERNEL_VERSION}-advanced-${ROOT_UUID}' {
        recordfail
        load_video
        gfxmode \$linux_gfx_mode
        insmod gzio
        if [ x\$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
        insmod part_gpt
        insmod ext2
        search --no-floppy --fs-uuid --set=root ${CHBOOT_UUID}
        echo    'Loading Linux ${KERNEL_VERSION} for CHBOOT RESTORE ...'
        linux   /boot/vmlinuz-${KERNEL_VERSION} root=PARTUUID=${ROOT_PARTUUID} ro boot=chboot chb.ncurses chb.uuid=${ROOT_UUID} chb.efi=UUID=${EFI_UUID} chb.dev=UUID=${CHBOOT_UUID} chb.dir=/${CHBOOT_DIRNAME} $CHBOOT_URL_OPTION net.ifnames=0 rw $vt_handoff
        echo    'Loading initial ramdisk ...'
        initrd  /boot/${CHBOOT_INITRD}
}

search --no-floppy --fs-uuid --set=oldroot ${ROOT_UUID}
if [ -e (\$oldroot)/boot/grub/grub.cfg ] ; then
	menuentry 'Run old grub configuration to start LliureX' {
		configfile (\$oldroot)/boot/grub/grub.cfg 
	}
fi

EOF
}

######### MAIN ##########

if [ $(id -u) -ne 0 ] ; then
	echo "Ypu must run this script as root to preserve all file atributes" >&2
	usage
fi

# create initrd and copy kernel to chboot boot dir
#
mkdir -p "$BOOT_DIR"
mkinitramfs -d initramfs-tools/  -o $BOOT_DIR/initrd_chboot.img-$(uname -r)
cp /boot/vmlinuz-$(uname -r) $BOOT_DIR/

# generate grub.cfg 
mkdir -p "$BOOT_DIR/grub"

GRUB_DISABLE_RECOVERY=true
GRUB_DISABLE_SUBMENU=true
[ "$CHBOOT_TITLE" ] || CHBOOT_TITLE="Unattended LliureX 25 install from DISK image"
CHBOOT_URL_OPTION=""
if [ "$CHBOOT_URL" ] ; then
	CHBOOT_URL_OPTION="chb.url=$CHBOOT_URL"
fi

# preserve files
FILE_LIST="depends.txt"
if [ -z "$FILE_LIST" ] || [ ! -s "$FILE_LIST" ] ; then
	exit 0
fi

DEST_DIR="$CHBOOT_DIR/files"
mkdir -p "$DEST_DIR"
rsync -a --files-from=$FILE_LIST / "$DEST_DIR"

# preserve tags
TAGS_DIR_LIST="/etc/lliurex-auto-upgrade/tags"

for d in $TAGS_DIR_LIST ; do
	find $d |grep -v "\." |rsync -a --files-from=- / "$DEST_DIR"
done


# find chboot initrd
CHBOOT_INITRD=""

CHBOOT_INITRD="$(ls -1 "$BOOT_DIR" | grep "^initrd_chboot.img" |tail -1)"
[ "$CHBOOT_INITRD" ] || exit 0

KERNEL_VERSION="${CHBOOT_INITRD#*-}"

# find chboot partition
CHBOOT_BY_LABEL="/dev/disk/by-label/chboot"
[ -e "$CHBOOT_BY_LABEL" ] || exit 0
CHBOOT_PART="$(readlink -f "$CHBOOT_BY_LABEL")"
CHBOOT_UUID="$(lsblk -nplo UUID "$CHBOOT_PART")"

# find current root partition
ROOT_UUID="$(get_uuid "/")"
ROOT_PARTUUID="$(get_partuuid "/")"
if [ -z "$ROOT_UUID" ] || [ -z "$ROOT_PARTUUID" ] ; then
	exit 0
fi

# find efi partition
EFI_UUID="$(get_uuid "/boot/efi")"
[ "$EFI_UUID" ] || exit 0

gen_grub_cfg > "$BOOT_DIR/grub/grub.cfg"

