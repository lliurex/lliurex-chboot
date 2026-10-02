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

# include jammy and noble dirs

for d in usr/share lib ; do
	if [ -d  /$d/terminfo  ] ; then
		mkdir -p ${DESTDIR}/$d
		cp -r /$d/terminfo ${DESTDIR}/$d
	fi
done

