#!/bin/bash

top=$(pwd)

extract_firmware() {
    cd "$top/firmware-mod-kit"
    ./extract-firmware.sh "$top"/upgrade-"$upstream_version".bin
    cd "$top"
    echo "$upstream_version" > configs/.upstream_version
    mkdir openwrt-cc/files
    cp -r firmware-mod-kit/fmk/rootfs/* openwrt-cc/files/
    rm -rf openwrt-cc/files/lib/modules/*
    rm -rf openwrt-cc/files/sbin/modprobe
}

apt_get() {
    # Clean this up
    sudo apt-get update
    sudo apt-get install -y \
    git build-essential zlib1g-dev liblzma-dev python-magic subversion \
    build-essential git-core libncurses5-dev zlib1g-dev gawk flex quilt \
    ibssl-dev xsltproc libxml-parser-perl mercurial bzr ecj cvs unzip
}

first_run() {
    cd "$top"
    #apt_get
    #git submodule update --recursive --remote
    wget https://www.wifipineapple.com/downloads/nano/latest -O upgrade-"$upstream_version".bin
    echo "BINWALK=binwalk" >> firmware-mod-kit/shared-ng.inc
    touch configs/.upstream_version
    cp configs/gl-ar150-defconfig openwrt-cc/.config
    mkdir firmware_images
    extract_firmware
}

install_scripts() {
    cd "$top/openwrt-cc"
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

build_firmware() {
    cd "$top/openwrt-cc"
    make -j$(cat /proc/cpuinfo | grep "^processor" | wc -l)
    for line in $(find "$top/openwrt-cc/bin" -name "*-sysupgrade.bin"); do
        cp "$line" "$top/firmware_images/"
        echo " - [*] File ready at - $line"
    done
   cd "$top"
}

full_build() {
    upstream_version=`curl -s https://www.wifipineapple.com/downloads/nano/ | \
            python -c "import sys, json; print(json.load(sys.stdin)['version'])"`
    current_version=`cat configs/.upstream_version`

    if [ -f "configs/.upstream_version" ]; then
        echo "config file found"
        git submodule update
    else
        echo "config file not found"
        first_run
    fi

    if [ "$upstream_version" < "$current_version" ]; then
        extract_firmware
    fi

    install_scripts

    make defconfig
    build_firmware
}

if [ "$1" = "-f" ]; then
    rm configs/.upstream_version
    full_build
elif
    [ "$1" = "-c" ]; then
    rm -rf firmware_images
    rm -rf firmware-mod-kit/fmk
    cd openwrt-cc
    make dirclean
    # do I need sudo doe?
    rm -rf files
    cd ..
elif
    [ -z "$1" ]; then
    full_build
fi
