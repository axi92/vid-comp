#!/bin/bash
set -e

# Use environment variables with defaults
INPUT_DIR="${INPUT_DIR:-/input}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"
MIN_VMAF="${MIN_VMAF:-94}"
FILE_PATTERN="${FILE_PATTERN:-*.mp4|*.mkv}"
EXCLUDE_PATTERN="${EXCLUDE_PATTERN:-*.x265.mkv}"

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

echo "=== Video Conversion Wrapper ==="
echo "Input dir: ${INPUT_DIR}"
echo "Output dir: ${OUTPUT_DIR}"
echo "Min VMAF: ${MIN_VMAF}"
echo "File pattern: ${FILE_PATTERN}"
echo "Exclude pattern: ${EXCLUDE_PATTERN}"

# Parse file patterns into separate -name options for find
# FILE_PATTERN is pipe-separated like "*.mp4|*.mkv"
IFS='|' read -ra PATTERNS <<< "${FILE_PATTERN}"

# Build find command arguments
FIND_ARGS=()
for pattern in "${PATTERNS[@]}"; do
    if [ ${#FIND_ARGS[@]} -eq 0 ]; then
        FIND_ARGS+=("-name" "${pattern}")
    else
        FIND_ARGS+=("-o" "-name" "${pattern}")
    fi
done

# Add exclude pattern if specified
if [ -n "${EXCLUDE_PATTERN}" ] && [ "${EXCLUDE_PATTERN}" != "none" ]; then
    FIND_ARGS+=("-not" "-name" "${EXCLUDE_PATTERN}")
fi

echo ""
echo "=== Processing Files ==="

# Find and process files
find "${INPUT_DIR}" -type f \( "${FIND_ARGS[@]}" \) -print0 | while IFS= read -r -d '' file; do
    # Get relative path from input dir
    rel_path="${file#${INPUT_DIR}/}"

    # Create output path preserving directory structure
    output_file="${OUTPUT_DIR}/${rel_path%.*}.x265.mkv"
    output_subdir=$(dirname "${output_file}")

    # Create output subdirectory if needed
    mkdir -p "${output_subdir}"

    echo ""
    echo "Processing: ${file}"
    echo "  -> ${output_file}"

    ab-av1 auto-encode \
        -i "${file}" \
        --encoder libx265 \
        --min-vmaf "${MIN_VMAF}" \
        --acodec aac \
        -o "${output_file}"

    echo "Done: ${file}"
done

echo ""
echo "=== All files processed ==="
