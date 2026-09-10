FROM ubuntu:26.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    INPUT_DIR=/input \
    OUTPUT_DIR=/output \
    MIN_VMAF=94 \
    FILE_PATTERN="*.mp4|*.mkv" \
    EXCLUDE_PATTERN="*.x265.mkv" \
    UID=1000 \
    GID=1000

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
    && rm -rf /var/lib/apt/lists/*

# Download and extract FFmpeg
RUN mkdir -p /opt/ffmpeg && \
    cd /opt && \
    wget -q https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz && \
    tar -xf ffmpeg-master-latest-linux64-gpl.tar.xz && \
    mv ffmpeg-master-latest-linux64-gpl ffmpeg && \
    rm ffmpeg-master-latest-linux64-gpl.tar.xz

# Set up FFmpeg PATH
ENV PATH="/opt/ffmpeg/bin:$PATH"

# Download ab-av1 binary
RUN curl -sL https://api.github.com/repos/alexheretic/ab-av1/releases/latest > /tmp/release.json; \
    jq -r '.assets[] | select(.name | contains("x86_64-unknown-linux-musl.tar.gz")) | .browser_download_url' /tmp/release.json > /tmp/ab_av1_url.txt; \
    curl -sL -o /tmp/ab-av1.tar.gz "$(cat /tmp/ab_av1_url.txt)"; \
    tar -xf /tmp/ab-av1.tar.gz -C /tmp; \
    mv /tmp/ab-av1*/ab-av1 /usr/local/bin/ab-av1; \
    chmod +x /usr/local/bin/ab-av1; \
    rm -f /tmp/ab-av1.tar.gz /tmp/ab_av1_url.txt /tmp/release.json

# Create input/output directories
RUN mkdir -p ${INPUT_DIR} ${OUTPUT_DIR}

# Set working directory
WORKDIR /app

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Change to non-root user (use UID/GID 1000 which exists as 'ubuntu' user in ubuntu:26.04)
USER ${UID}

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
