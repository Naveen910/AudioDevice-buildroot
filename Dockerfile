# Use a minimal base image suitable for building
FROM ubuntu:22.04

# 1. Install Build Dependencies
# We disable interactive prompts to prevent the build from hanging
# 1. Install Build Dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    bash \
    bc \
    binutils \
    bzip2 \
    cpio \
    file \ 
    g++ \
    gcc \
    git \
    gzip \
    locales \
    libncurses5-dev \
    libdevmapper-dev \
    libsystemd-dev \
    make \
    mercurial \
    whois \
    patch \
    perl \
    python3 \
    rsync \
    sed \
    tar \
    unzip \
    wget \
    bison \
    flex \
    libssl-dev \
    libfdt-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Set up Locale (Required by Buildroot)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 3. Clone Buildroot (Fixed Version for Stability)
WORKDIR /workspace
RUN git clone --depth 1 --branch 2024.02.x https://github.com/buildroot/buildroot.git buildroot

# 4. Copy YOUR Custom Tree into the Container
# This copies the folder from your Mac into the Docker image
COPY custom-f1c100s-buildroot /workspace/custom-f1c100s-buildroot

# 5. Configure Buildroot
# We tell Buildroot to look at your custom folder and load 'my_defconfig'
WORKDIR /workspace/buildroot
RUN make BR2_EXTERNAL=/workspace/custom-f1c100s-buildroot my_defconfig

# 6. Run the Build
# This takes a long time!
# RUN make

# 7. (Optional) Default command
# If you run the container manually, it drops you into a shell
CMD ["/bin/bash"]