#!/bin/bash

# TurboGet - Smart file downloader that chooses the fastest method (curl or aria2c)

# === Parse Arguments ===
SHOW_HELP=false
VERBOSE=false
OUT_DIR="$(pwd)"

print_help() {
  echo "Usage: $0 [options] <file_url>"
  echo
  echo "Options:"
  echo "  -o <directory>   Set output download directory"
  echo "  -h               Show this help message"
  exit 0
}

while getopts ":o:h" opt; do
  case ${opt} in
    o ) OUT_DIR="$OPTARG" ;;
    h ) print_help ;;
    \? ) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    : ) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

shift $((OPTIND -1))
FILE_URL="$1"
FILE_NAME=$(basename "$FILE_URL")
TEMP_DIR=$(mktemp -d)
TEST_BYTES=1000000  # 1MB test range

if [ -z "$FILE_URL" ]; then
  echo "Usage: $0 [-o <output_directory>] <file_url>"
  exit 1
fi

echo "[TurboGet] Testing best method to download: $FILE_NAME"
echo

# === Function: Speed test using curl ===
test_curl() {
  echo "Testing curl..."
  speed=$(curl -s -o /dev/null --range 0-${TEST_BYTES} -w "%{speed_download}" "$FILE_URL")
  speed_int=${speed%.*}
  echo "curl speed: $((speed_int / 1024)) KB/s"
  echo "$speed_int" > "$TEMP_DIR/curl_speed"
}

# === Function: Speed test using aria2c ===
test_aria2() {
  echo "Testing aria2c..."
  aria2c --download-result=hide --summary-interval=0 \
         --dir="$TEMP_DIR" \
         --max-download-limit=1M \
         --stop-with-process=$$ \
         --allow-overwrite=true \
         --header="Range: bytes=0-${TEST_BYTES}" \
         -x 8 -s 8 -o "test" "$FILE_URL" > /dev/null 2>&1

  if [[ -f "$TEMP_DIR/test" ]]; then
    size=$(wc -c < "$TEMP_DIR/test")
    echo "aria2c received $((size / 1024)) KB"
    echo "$size" > "$TEMP_DIR/aria2_speed"
  else
    echo "aria2c failed"
    echo "0" > "$TEMP_DIR/aria2_speed"
  fi
}

# === Run speed tests ===
test_curl
test_aria2

# === Load results ===
speed_curl=$(cat "$TEMP_DIR/curl_speed")
speed_aria2=$(cat "$TEMP_DIR/aria2_speed")

# === Compare and download ===
echo
mkdir -p "$OUT_DIR"

if (( speed_aria2 > speed_curl )); then
  echo "✅ [TurboGet] Using aria2c (faster)"
  aria2c -x 16 -s 16 -k 1M -d "$OUT_DIR" -o "$FILE_NAME" "$FILE_URL"
else
  echo "✅ [TurboGet] Using curl (faster)"
  curl -# -L -o "$OUT_DIR/$FILE_NAME" "$FILE_URL"
fi

# === Cleanup ===
rm -rf "$TEMP_DIR"
