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
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Download and extract FFmpeg
RUN mkdir -p /opt/ffmpeg && \
    cd /opt && \
    wget -q https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz && \
    tar -xf ffmpeg-master-latest-linux64-gpl.tar.xz && \
    mv ffmpeg-master-latest-linux64-gpl ffmpeg && \
    rm ffmpeg-master-latest-linux64-gpl.tar.xz

# Set up FFmpeg PATH
ENV PATH="/opt/ffmpeg/bin:/usr/bin:$PATH"

# Download ab-av1 binary
RUN curl -sL "$(curl -sL https://api.github.com/repos/alexheretic/ab-av1/releases/latest | jq -r '.assets[] | select(.name | contains("linux-musl")) | .browser_download_url')" | tar -I zstd -xv -C /usr/local/bin

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
