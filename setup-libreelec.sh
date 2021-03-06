#!/bin/sh

set -xe

die() {
        printf '\033[1;31mERROR:\033[0m %s\n' "$@" >&2  # bold red
        exit 1
}

which docker > /dev/null || die 'please install docker'
which docker-compose > /dev/null || die 'please install docker-compose with: sudo pip3 install docker-compose'

cd "$(dirname "$0")"

DEST=$(pwd)

url="http://releases.libreelec.tv/LibreELEC-RPi2.arm-8.2.5.tar"

server_ip=$(ip route get 1 | awk '{print $NF;exit}')

mkdir -p os/boot os/root

rm -rf os/boot/*

wget $url -O- | tar -C os/boot --strip=1 -xf -

mv os/boot/3rdparty/bootloader/* os/boot/

mv os/boot/target/* os/boot/

rm -r os/boot/3rdparty os/boot/target

echo "boot=NFS="$server_ip":/nfsshare/boot disk=NFS="$server_ip":/nfsshare/root quiet ssh ip=dhcp" > os/boot/cmdline.txt

echo "kernel=KERNEL" >> os/boot/config.txt

docker-compose up -d

