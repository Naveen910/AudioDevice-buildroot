#!/bin/bash
set -e

# ---- CONFIG ----
BUILDROOT_VERSION=2023.02.9
BUILDROOT_DIR="buildroot"
EXTERNAL_DIR="custom-f1c100s-buildroot"

O="/tmp/br-output"
DL="/tmp/br-dl"

# ---- Sanity Checks ----
if [ ! -d "$EXTERNAL_DIR" ]; then
    echo "ERROR: External tree '$EXTERNAL_DIR' not found!"
    exit 1
fi

# ---- Download Buildroot if not present ----
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "Downloading Buildroot ${BUILDROOT_VERSION}..."
    wget https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz
    tar -xf buildroot-${BUILDROOT_VERSION}.tar.gz
    mv buildroot-${BUILDROOT_VERSION} "$BUILDROOT_DIR"
fi

mkdir -p "$O" "$DL"
cd "$BUILDROOT_DIR"

# ---- Load defconfig ----
make O="$O" \
     BR2_DL_DIR="$DL" \
     BR2_EXTERNAL="../${EXTERNAL_DIR}" \
     my_defconfig

# ---- If user wants interactive config ----
if [ "$1" = "menu" ]; then

    echo "Opening Buildroot menuconfig..."
    make O="$O" \
         BR2_DL_DIR="$DL" \
         BR2_EXTERNAL="../${EXTERNAL_DIR}" \
         menuconfig

    echo "Saving Buildroot defconfig..."
    make O="$O" \
         BR2_DL_DIR="$DL" \
         BR2_EXTERNAL="../${EXTERNAL_DIR}" \
         savedefconfig \
         BR2_DEFCONFIG="../${EXTERNAL_DIR}/configs/my_defconfig"

    echo "Opening Linux kernel menuconfig..."
    make O="$O" \
         BR2_DL_DIR="$DL" \
         BR2_EXTERNAL="../${EXTERNAL_DIR}" \
         linux-menuconfig

    echo "Saving Linux kernel defconfig..."
    make O="$O" \
         BR2_DL_DIR="$DL" \
         BR2_EXTERNAL="../${EXTERNAL_DIR}" \
         linux-update-defconfig
fi

# ---- Final build ----
echo "Building Buildroot..."
make O="$O" \
     BR2_DL_DIR="$DL" \
     BR2_EXTERNAL="../${EXTERNAL_DIR}"

echo "Build completed successfully!"
echo "Output images are in: $O/images"