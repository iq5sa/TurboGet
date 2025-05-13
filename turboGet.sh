#!/bin/bash

# TurboGet - Smart file downloader that chooses the fastest method (curl or aria2c)

# === Configuration ===
FILE_URL="$1"
FILE_NAME=$(basename "$FILE_URL")
TEMP_DIR=$(mktemp -d)
TEST_BYTES=1000000  # 1MB test range

if [ -z "$FILE_URL" ]; then
  echo "Usage: $0 <file_url>"
  exit 1
fi

echo "[TurboGet] Testing best method to download: $FILE_NAME"
echo

# === Function: Speed test using curl ===
test_curl() {
  echo "Testing curl..."
  speed=$(curl -s -o /dev/null --range 0-${TEST_BYTES} -w "%{speed_download}" "$FILE_URL")
  echo "curl speed: $((speed/1024)) KB/s"
  echo "$speed"
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
    echo "$size"
  else
    echo "aria2c failed"
    echo "0"
  fi
}

# === Run tests ===
speed_curl=$(test_curl)
speed_aria2=$(test_aria2)

# === Compare and choose ===
echo
if (( speed_aria2 > speed_curl )); then
  echo "✅ [TurboGet] Using aria2c (faster)"
  aria2c -x 16 -s 16 -k 1M -o "$FILE_NAME" "$FILE_URL"
else
  echo "✅ [TurboGet] Using curl (faster)"
  curl -L -o "$FILE_NAME" "$FILE_URL"
fi

# Cleanup
rm -rf "$TEMP_DIR"
