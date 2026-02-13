#!/bin/bash

# 1. Build the image quietly
docker build -t audio-builder . > /dev/null

echo "Entering Development Environment..."

docker run -it --rm \
    -v "$(pwd):/workspace" \
    -v "f1c100s_build_cache:/workspace/buildroot/output" \
    -e FORCE_UNSAFE_CONFIGURE=1 \
    --entrypoint /bin/bash \
    audio-builder -c "
        export TERM=xterm-256color

        # --- MISSING STEP 1: Ensure Buildroot exists ---
        if [ ! -d \"/workspace/buildroot\" ]; then
            echo '--- Cloning Buildroot (Skipped by entrypoint override) ---'
            git clone --depth 1 --branch 2024.02.x https://github.com/buildroot/buildroot.git /workspace/buildroot
        fi

        # --- MISSING STEP 2: Fix Permissions ---
        if [ -f \"/workspace/custom-f1c100s-buildroot/board/post-image.sh\" ]; then
             chmod +x /workspace/custom-f1c100s-buildroot/board/post-image.sh
             echo '--- Permissions fixed for post-image.sh ---'
        fi

        cd /workspace/buildroot

        # Helper function for kernel menuconfig
        function prep_kernel() {
            echo '--- Preparing Linux Kernel Source ---'
            make linux-patch
        }

        # Check config
        if [ ! -f .config ]; then
            echo '--- No .config found. Loading my_defconfig ---'
            make BR2_EXTERNAL=../custom-f1c100s-buildroot my_defconfig
        fi
        
        echo -e '\n--- Environment Ready ---'
        exec bash
    "