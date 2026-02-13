#!/bin/bash

# 1. Build the image quietly
docker build -t audio-builder . > /dev/null

# 2. Run Interactive Shell (ROOT MODE)
# Key Change: We mount a named volume 'f1c100s_build_cache' to /workspace/buildroot/output
# This keeps the temporary build files INSIDE Docker (fast, correct permissions)
# while keeping your source code and configs on your Mac.

echo "Entering Development Environment..."

docker run -it --rm \
    -v "$(pwd):/workspace" \
    -v "f1c100s_build_cache:/workspace/buildroot/output" \
    -e FORCE_UNSAFE_CONFIGURE=1 \
    --entrypoint /bin/bash \
    audio-builder -c "
        export TERM=xterm-256color
        
        # Go to buildroot
        cd /workspace/buildroot
        
        # Load config
        echo '--- Loading Config ---'
        make O=output BR2_EXTERNAL=../custom-f1c100s-buildroot my_defconfig

        
        echo -e '\n--- Environment Ready ---'
        echo 'Note: The 'output/' folder is now inside a Docker Volume.'
        echo 'Your source code changes will still save to your Mac.'
        echo 'Run: make menuconfig or make linux-menuconfig to start building.'
        
        exec bash
    "