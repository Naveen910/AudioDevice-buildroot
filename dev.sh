#!/bin/bash

# 1. Build the image if it doesn't exist
docker build -t audio-builder . > /dev/null

# 2. Run Interactive Shell
# --entrypoint /bin/bash: Overrides your entrypoint.sh script
# -it: Gives you an interactive terminal
echo "Entering Development Environment..."
docker run -it --rm \
    -v "$(pwd):/workspace" \
    -v "$(pwd)/build-output:/output" \
    --user $(id -u):$(id -g) \
    --entrypoint /bin/bash \
    audio-builder