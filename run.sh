#!/bin/bash

# 1. Build the Docker image (only needs to happen once, but safe to run repeatedly)
docker build -t audio-builder .

# 2. Create local output directory
mkdir -p build-output

# 3. Run the container
# We map current dir ($PWD) to /workspace
# We map build-output to /output
docker run --rm \
    -v "$(pwd):/workspace" \
    -v "$(pwd)/build-output:/output" \
    --user $(id -u):$(id -g) \
    audio-builder