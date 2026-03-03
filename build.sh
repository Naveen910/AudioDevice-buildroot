#!/bin/bash
set -e

# ---- CONFIG ----
BUILDROOT_VERSION=2023.02.9
BUILDROOT_DIR="buildroot"
EXTERNAL_DIR="custom-f1c100s-buildroot"

PROJECT_DIR="$(pwd)"
EXTERNAL_PATH="${PROJECT_DIR}/${EXTERNAL_DIR}"
DEFCONFIG_PATH="${EXTERNAL_PATH}/configs/my_defconfig"

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

# ---- Interactive configuration mode ----
if [ "$1" = "menu" ]; then

    echo ""
    echo "Entering interactive configuration shell..."
    echo ""
    echo "Run any of the following:"
    echo "  make menuconfig"
    echo "  make linux-menuconfig"
    echo "  make busybox-menuconfig"
    echo ""
    echo "When finished, type: exit"
    echo ""

    export MAKEFLAGS="O=$O BR2_DL_DIR=$DL BR2_EXTERNAL=$EXTERNAL_PATH"

    bash --noprofile --norc

    echo ""
    echo "Saving Buildroot defconfig..."
    make O="$O" \
         BR2_DL_DIR="$DL" \
         BR2_EXTERNAL="$EXTERNAL_PATH" \
         savedefconfig \
         BR2_DEFCONFIG="$DEFCONFIG_PATH"

    # Save kernel config if exists
    if ls "$O/build" | grep -q linux 2>/dev/null; then
        echo "Saving Linux kernel defconfig..."
        make O="$O" \
             BR2_DL_DIR="$DL" \
             BR2_EXTERNAL="$EXTERNAL_PATH" \
             linux-update-defconfig
    fi

    # Save BusyBox config if exists
    if ls "$O/build" | grep -q busybox 2>/dev/null; then
        echo "Saving BusyBox config..."
        make O="$O" \
             BR2_DL_DIR="$DL" \
             BR2_EXTERNAL="$EXTERNAL_PATH" \
             busybox-update-config
    fi

    echo ""
    echo "All configurations saved successfully!"
    echo ""
    exit 0
fi

# ---- Final build ----
echo "Building Buildroot..."
make O="$O" \
     BR2_DL_DIR="$DL" \
     BR2_EXTERNAL="../${EXTERNAL_DIR}"

mkdir -p ../output-images
cp -r "$O/images/"* ../output-images/

echo "Build completed successfully!"
echo "Images copied to: output-images/"