#!/bin/bash
set -e

# ---- CONFIG ----
BUILDROOT_VERSION=2023.02.9
BUILDROOT_DIR=buildroot
EXTERNAL_DIR=custom-f1c100s-buildroot
OUTPUT_DIR=output

# ---- Download Buildroot if not present ----
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "Downloading Buildroot..."
    wget https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz
    tar -xvf buildroot-${BUILDROOT_VERSION}.tar.gz
    mv buildroot-${BUILDROOT_VERSION} ${BUILDROOT_DIR}
fi

# ---- Buildroot commands ----
mkdir -p /tmp/br-output /tmp/br-dl
cd ${BUILDROOT_DIR}

make O=/tmp/br-output \
     BR2_DL_DIR=/tmp/br-dl \
     BR2_EXTERNAL=../custom-f1c100s-buildroot \
     my_defconfig

make O=/tmp/br-output \
     BR2_EXTERNAL=../custom-f1c100s-buildroot \
     menuconfig

make O=/tmp/br-output \
     BR2_EXTERNAL=../custom-f1c100s-buildroot \
     linux-menuconfig

#make O=/tmp/br-output \
#    BR2_EXTERNAL=../custom-f1c100s-buildroot

#cp -r /tmp/br-output/images ../output-images

echo "Build completed!"
