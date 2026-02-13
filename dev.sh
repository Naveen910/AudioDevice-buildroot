#!/bin/bash

# 1. Build the image
docker build -t audio-builder . > /dev/null

# 2. Run Interactive Shell with Pre-loaded Config
echo "Entering Development Environment..."
docker run -it --rm \
    -v "$(pwd):/workspace" \
    -v "$(pwd)/build-output:/output" \
    --user $(id -u):$(id -g) \
    --entrypoint /bin/bash \
    audio-builder -c "
        cd buildroot && \
        make BR2_EXTERNAL=../custom-f1c100s-buildroot my_defconfig && \
        exec bash
    "