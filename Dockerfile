FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Buildroot dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    unzip \
    rsync \
    bc \
    bison \
    flex \
    libssl-dev \
    libncurses5-dev \
    libncursesw5-dev \
    cpio \
    python3 \
    file \
    locales \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# Working directory
WORKDIR /build

# Default command
CMD ["/bin/bash"]
