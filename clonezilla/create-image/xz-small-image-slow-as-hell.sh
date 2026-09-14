#!/bin/sh
partclone.ext4 -c -s /dev/sda2 |xz -9e -c > sda2-image.xz
# 2 hrs (VBox VM machine, same machine as stz) to compress 26.5 GB (16.6 GB in use) to 5.6 GB
# restore time ???????
#restore using xzcat sda2-image.xz | ...
