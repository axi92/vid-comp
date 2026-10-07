FROM ubuntu:26.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    INPUT_DIR=/input \
    OUTPUT_DIR=/output \
    MIN_VMAF=94 \
    FILE_PATTERN="*.mp4|*.mkv" \
    EXCLUDE_PATTERN="*.x265.mkv" \
    UID=1000 \
    GID=1000 \
    AB_AV1_VERSION=0.11.7

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    tar \
    jq \
    build-essential \
    pkg-config \
    libclang-dev \
    python3 \
    python3-pip \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Download and extract FFmpeg directly into /opt/ffmpeg
RUN mkdir -p /opt/ffmpeg && \
    wget -qO- https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz | \
    tar -xJ -C /opt/ffmpeg --strip-components=1

# Set up FFmpeg PATH
ENV PATH="/opt/ffmpeg/bin:/usr/bin:$PATH"

# Download ab-av1 binary
RUN curl -sL "https://github.com/alexheretic/ab-av1/releases/download/v${AB_AV1_VERSION}/ab-av1-v${AB_AV1_VERSION}-x86_64-unknown-linux-musl.tar.zst" | tar -I zstd -xv -C /usr/local/bin

# Create input/output directories
RUN mkdir -p ${INPUT_DIR} ${OUTPUT_DIR}

RUN mkdir -p /app && \
    chown -R ${UID}:${GID} /app

# Set working directory
WORKDIR /app

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Change to non-root user (use UID/GID 1000 which exists as 'ubuntu' user in ubuntu:26.04)
USER ${UID}

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
