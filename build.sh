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
cd ${BUILDROOT_DIR}

echo "Loading external defconfig..."
make BR2_EXTERNAL=../${EXTERNAL_DIR} my_defconfig

echo "Opening Buildroot menuconfig..."
make menuconfig

echo "Opening Linux kernel menuconfig..."
make linux-menuconfig

echo "Building Buildroot..."
make

echo "Build completed!"
