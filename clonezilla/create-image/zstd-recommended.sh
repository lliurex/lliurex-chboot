#!/bin/sh
partclone.ext4 -c -s /dev/sda2 |zstd -19 -T0 > sda2-image.zst
# 1:22:19 (VBox VM machine, same machine as xz) to compress 26.5 GB (16.6 GB in use) to 6.0 GB
#restore using zstdcat sda2-image.zst | ...
