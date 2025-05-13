# TurboGet 🚀

TurboGet is a smart, dynamic file downloader that benchmarks `curl` and `aria2c` to select the fastest method for your current network.

## Features

- Real-time speed testing
- Segment downloading via `aria2c`
- Clean fallback to `curl`
- Lightweight and fast

## Requirements

- macOS or Linux
- `curl` (built-in)
- `aria2c` (install via `brew install aria2` or `sudo apt install aria2`)

## Usage

```bash
chmod +x turbo-get.sh
./turbo-get.sh "https://example.com/yourfile.zip"
