# VideOCR Arch Linux Installer

[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> 🚀 **One-command VideOCR installation!** Automated installer script for Arch Linux and derivatives.

This is an **unofficial** installer that automates the setup of [VideOCR](https://github.com/timminator/VideOCR) on Arch Linux systems. It downloads the pre-compiled binary, sets up Python environment, and creates desktop integration.

## 📋 Features

- ✅ **Automatic Download**: Downloads videocr-cli.bin automatically (~2.5GB)
- ✅ **Python Virtual Environment**: Creates isolated Python environment
- ✅ **Dependency Management**: Installs all Python libraries automatically
- ✅ **Tcl/Tk Fix**: Automatically resolves version compatibility issues
- ✅ **Desktop Integration**: Adds shortcut to KDE/GNOME application menu
- ✅ **Command Line**: Access from anywhere with `videocr` command

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/666subaru/videocr-arch-installer.git
cd videocr-arch-installer
```

### 2. Run the Installer

```bash
chmod +x install_videocr.sh
./install_videocr.sh
```

### 3. Launch VideOCR

```bash
# From command line
videocr

# Or from application menu
# Search for "VideOCR"
```

## 📦 Requirements

### System Requirements

- **OS**: Arch Linux or derivatives (Manjaro, EndeavourOS, etc.)
- **Python**: 3.8+
- **GPU**: NVIDIA GPU (CUDA support required)
- **Disk Space**: ~5GB free space

### Package Dependencies

The script automatically installs these if missing:

```bash
sudo pacman -S python python-pip p7zip curl git
```

## 🔧 Manual Installation (Optional)

If you prefer not to use the script:

```bash
# 1. Clone the original repository
git clone https://github.com/timminator/VideOCR.git ~/.local/share/videocr

# 2. Download binary files
cd ~/.local/share/videocr
curl -L -o videocr-cli-GPU-v1.4.2-CUDA-12.9-Linux.7z.001 \
    https://github.com/timminator/VideOCR/releases/download/v1.4.2/videocr-cli-GPU-v1.4.2-CUDA-12.9-Linux.7z.001
curl -L -o videocr-cli-GPU-v1.4.2-CUDA-12.9-Linux.7z.002 \
    https://github.com/timminator/VideOCR/releases/download/v1.4.2/videocr-cli-GPU-v1.4.2-CUDA-12.9-Linux.7z.002

# 3. Extract archives
7z x videocr-cli-GPU-v1.4.2-CUDA-12.9-Linux.7z.001

# 4. Create Python virtual environment
python -m venv .venv
source .venv/bin/activate

# 5. Install dependencies
pip install paddlepaddle-gpu==2.6.2 paddleocr==3.4.0 PySimpleGUI wakepy av numpy rapidfuzz
pip install opencc-python-reimplemented wordninja Pillow tqdm scikit-image pyclipper shapely
pip install opencv-python-headless langdetect pyyaml

# 6. Run
python VideOCR.py
```

## 📁 Installation Structure

```
~/.local/share/videocr/
├── .venv/                    # Python virtual environment
├── videocr-cli.bin          # Main binary file
├── VideOCR.py               # GUI application
├── tcl8.6/                  # Tcl libraries
├── tk8.6/                   # Tk libraries
└── Installer/
    └── VideOCR.png          # Application icon
```

## 🎮 Usage

### GUI Mode

```bash
videocr
```

Or search for **"VideOCR"** in your application menu.

### CLI Mode

```bash
~/.local/share/videocr/videocr-cli.bin --help
```

## 🐛 Troubleshooting

### "videocr: command not found" Error

```bash
# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Make permanent by adding to ~/.bashrc or ~/.config/fish/config.fish
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### Tcl/Tk Version Error

The script automatically fixes this, but for manual fix:

```bash
sed -i 's/package require -exact Tcl 8.6.16/package require -exact Tcl 8.6.12/g' \
    ~/.local/share/videocr/tcl8.6/init.tcl
```

### First Run Slowness

On first run, PaddleOCR models will be downloaded (may take a few minutes).

## 📝 License

This project is licensed under the [MIT License](LICENSE).

## 🙏 Credits

- [VideOCR](https://github.com/timminator/VideOCR) - Original project by timminator
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) - OCR engine

## 👨‍💻 Developer

**666subaru** - *Arch Linux Installer*

- GitHub: [@666subaru](https://github.com/666subaru)

---

⭐ **If you like this project, don't forget to give it a star!**

## 📝 Note

This is an **unofficial** installer. All credit for VideOCR goes to the original author [timminator](https://github.com/timminator). This script simply automates the installation process for Arch Linux users.
