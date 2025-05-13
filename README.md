# TurboGet

**TurboGet** is a smart shell script that chooses the fastest download method (between `curl` and `aria2c`) dynamically, based on a quick speed test. Ideal for downloading large files from a CDN efficiently.

---

## 🚀 Features

- Speed test using both `curl` and `aria2c`
- Automatically selects the faster tool
- Shows progress bar during download
- Supports custom output directories
- Temporary test file is cleaned up automatically

---

## 🛠 Requirements

- `bash`
- `curl`
- `aria2c`

Install `aria2` on macOS:
```bash
brew install aria2
```

---

## 📦 Usage

```bash
./turbo-get.sh [options] <file_url>
```

### Options:

| Option | Description                      |
|--------|----------------------------------|
| `-o`   | Set output directory             |
| `-h`   | Show help                        |

### Example:

```bash
./turbo-get.sh -o ~/Downloads https://example.com/file.mp4
```

---

## 📂 Output
Downloaded files will be saved to the specified output directory (defaults to current directory).

---

## ✅ License
MIT License

---

## 🤝 Contributing
Pull requests and suggestions are welcome!
