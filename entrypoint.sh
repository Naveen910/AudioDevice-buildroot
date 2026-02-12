#!/bin/bash
set -e

# --- 1. Fix Permissions (Crucial Step) ---
# We force the post-image script to be executable inside the container
chmod +x /workspace/custom-f1c100s-buildroot/board/post-image.sh
echo "Permissions fixed for post-image.sh"

# --- 2. Setup Variables ---
WORKSPACE="/workspace"
BUILDROOT_DIR="${WORKSPACE}/buildroot"
EXTERNAL_TREE="${WORKSPACE}/custom-f1c100s-buildroot"
OUTPUT_DIR="/output"

# --- 3. Get Buildroot Source ---
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "Buildroot source not found. Cloning LTS 2024.02..."
    git clone --depth 1 --branch 2024.02.x https://github.com/buildroot/buildroot.git "$BUILDROOT_DIR"
fi

# --- 4. Configure ---
# We use the 'my_defconfig' from your custom tree
echo "Configuring Buildroot..."
make -C "$BUILDROOT_DIR" \
    BR2_EXTERNAL="$EXTERNAL_TREE" \
    O="$BUILDROOT_DIR/output" \
    my_defconfig

# --- 5. Build ---
echo "Starting Build..."
make -C "$BUILDROOT_DIR" O="$BUILDROOT_DIR/output"

# --- 6. Deliver Artifacts ---
echo "Copying images to output..."
# Copy only the final images (sdcard.img, u-boot, etc) to your host folder
cp -r "$BUILDROOT_DIR/output/images/"* "$OUTPUT_DIR/"

echo "SUCCESS: Image built at $(date)"