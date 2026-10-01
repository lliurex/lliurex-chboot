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

# Copy terminfo data from host
# TODO: copy only required data

mkdir -p ${DESTDIR}/usr/share
cp -r /usr/share/terminfo ${DESTDIR}/usr/share/

