#!/bin/sh
DEST_PART=/dev/sda5

# preserve root partition UUID
DEST_UUID="$(lsblk -plo NAME,UUID |sed -ne "\%^\s*$DEST_PART%{s%$DEST_PART%%;s%\s*%%;p}")"

zstdcat sda2.ext4-ptcl-img.zst |partclone.restore -I -C -d -s - -o $DEST_PART

e2fsck -f $DEST_PART
resize2fs $DEST_PART

tune2fs -U "$DEST_UUID" "$DEST_PART"

