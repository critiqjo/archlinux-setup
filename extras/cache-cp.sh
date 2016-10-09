#!/bin/bash

set -e

find /var/cache/pacman/pkg/ | grep -F -f pkgs | xargs -I % bash -c 'echo %; cp % /mnt/pendrv/pkg/'
