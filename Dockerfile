FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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
    python3-pip \
    python3-dev \
    swig \
    file \
    locales \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install pylibfdt Python bindings
RUN pip3 install --no-cache-dir pylibfdt

# Locale (optional)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

WORKDIR /build
CMD ["/bin/bash"]
