#!/bin/bash
if [[ $# != 2 ]]; then
	echo "Usage: $0 <mount_path> <vol_name>"
	exit 1
fi

path=`sed -e 's/\/$//'<<<$1`
vol=$2
echo "btrfs subvol snapshot -r $path/$vol $path/snaps/`date +%y%m%d-%H%M%S`_$vol"
