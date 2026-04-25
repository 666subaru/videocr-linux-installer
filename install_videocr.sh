#!/bin/bash

# VideOCR Otomatik Kurulum Betiği
# Arch Linux ve türevleri için
# Geliştirici: Halil İbrahim (Kimi ile birlikte)

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Değişkenler
INSTALL_DIR="$HOME/.local/share/videocr"
DESKTOP_FILE="$HOME/.local/share/applications/videocr.desktop"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
VENV_DIR="$INSTALL_DIR/.venv"
VERSION="1.5.0"

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     VideOCR Otomatik Kurulum Betiği (Arch Linux)       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Bağımlılıkları kontrol et
echo -e "${BLUE}[1/10]${NC} Bağımlılıklar kontrol ediliyor..."

MISSING_DEPS=()

for cmd in python pip 7z curl git; do
    if ! command -v $cmd &> /dev/null; then
        case $cmd in
            python) MISSING_DEPS+=("python");;
            pip) MISSING_DEPS+=("python-pip");;
            7z) MISSING_DEPS+=("p7zip");;
            curl) MISSING_DEPS+=("curl");;
            git) MISSING_DEPS+=("git");;
        esac
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${RED}❌ Eksik bağımlılıklar:${NC}"
    printf '   - %s\n' "${MISSING_DEPS[@]}"
    echo ""
    echo -e "${YELLOW}💡 Kurulum için:${NC}"
    echo "   sudo pacman -S ${MISSING_DEPS[*]}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Tüm bağımlılıklar mevcut"
echo ""

# 2. Kurulum dizinini oluştur
echo -e "${BLUE}[2/10]${NC} Kurulum dizini oluşturuluyor..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$ICON_DIR"
echo -e "${GREEN}✓${NC} Dizinler oluşturuldu"
echo ""

# 3. GitHub reposunu klonla
echo -e "${BLUE}[3/10]${NC} VideOCR reposu indiriliyor..."
if [ -d "$INSTALL_DIR/.git" ]; then
    cd "$INSTALL_DIR"
    git pull --quiet
else
    git clone --quiet https://github.com/timminator/VideOCR.git "$INSTALL_DIR"
fi
echo -e "${GREEN}✓${NC} Repo indirildi"
echo ""

# 4. videocr-cli.bin dosyalarını indir
echo -e "${BLUE}[4/10]${NC} videocr-cli binary dosyaları indiriliyor..."
cd "$INSTALL_DIR"

if [ ! -f "videocr-cli.bin" ]; then
    if [ ! -f "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.001" ]; then
        echo -e "${YELLOW}   ↳${NC} Part 1 indiriliyor (~2GB)..."
        curl -L --progress-bar -o "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.001" \
            "https://github.com/timminator/VideOCR/releases/download/v${VERSION}/videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.001"
    fi
    
    if [ ! -f "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.002" ]; then
        echo -e "${YELLOW}   ↳${NC} Part 2 indiriliyor (~450MB)..."
        curl -L --progress-bar -o "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.002" \
            "https://github.com/timminator/VideOCR/releases/download/v${VERSION}/videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.002"
    fi
    
    echo -e "${YELLOW}   ↳${NC} Arşivler açılıyor..."
    7z x -y "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.001" > /dev/null 2>&1
    
    # Dosyaları ana dizine kopyala
    cp -r "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux"/* .
    chmod +x videocr-cli.bin
    
    # Geçici dosyaları temizle
    rm -rf "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux"
    rm -f "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.001"
    rm -f "videocr-cli-GPU-v${VERSION}-CUDA-12.9-Linux.7z.002"
else
    echo -e "${GREEN}✓${NC} Binary dosya zaten mevcut, atlanıyor"
fi

echo -e "${GREEN}✓${NC} Binary dosyalar hazır"
echo ""

# 5. Python sanal ortamı oluştur
echo -e "${BLUE}[5/10]${NC} Python sanal ortamı oluşturuluyor..."
if [ ! -d "$VENV_DIR" ]; then
    python -m venv "$VENV_DIR"
fi
echo -e "${GREEN}✓${NC} Sanal ortam oluşturuldu"
echo ""

# 6. Python bağımlılıklarını kur
echo -e "${BLUE}[6/10]${NC} Python bağımlılıkları kuruluyor..."
source "$VENV_DIR/bin/activate"

pip install --quiet --upgrade pip

# Temel bağımlılıklar
pip install --quiet paddlepaddle-gpu==2.6.2
pip install --quiet paddleocr==3.4.0
pip install --quiet PySimpleGUI wakepy av numpy rapidfuzz
pip install --quiet opencc-python-reimplemented wordninja
pip install --quiet Pillow tqdm scikit-image pyclipper shapely
pip install --quiet opencv-python-headless langdetect pyyaml
pip install --quiet plyer

echo -e "${GREEN}✓${NC} Python bağımlılıkları kuruldu"
echo ""

# 7. Tcl/Tk dosyalarını hazırla
echo -e "${BLUE}[7/10]${NC} Tcl/Tk yapılandırması..."
if [ ! -d "$INSTALL_DIR/tcl8.6" ]; then
    mkdir -p "$INSTALL_DIR/tcl8.6"
    cp -r /usr/lib/tcl8.6/* "$INSTALL_DIR/tcl8.6/" 2>/dev/null || true
    # Versiyon kontrolünü düzelt
    sed -i 's/package require -exact Tcl 8.6.16/package require -exact Tcl 8.6.12/g' "$INSTALL_DIR/tcl8.6/init.tcl" 2>/dev/null || true
fi

if [ ! -d "$INSTALL_DIR/tk8.6" ]; then
    mkdir -p "$INSTALL_DIR/tk8.6"
    cp -r /usr/lib/tk8.6/* "$INSTALL_DIR/tk8.6/" 2>/dev/null || true
    # Versiyon kontrolünü düzelt
    sed -i 's/package require -exact Tk  8.6.16/package require -exact Tk  8.6.12/g' "$INSTALL_DIR/tk8.6/tk.tcl" 2>/dev/null || true
fi

echo -e "${GREEN}✓${NC} Tcl/Tk yapılandırması tamamlandı"
echo ""

# 8. .desktop dosyası oluştur
echo -e "${BLUE}[8/10]${NC} Masaüstü kısayolu oluşturuluyor..."
mkdir -p "$HOME/.local/share/applications"

# Wrapper script oluştur (KDE uyumluluğu için)
cat > "$HOME/.local/bin/videocr-launcher" << EOF
#!/bin/bash
export TCL_LIBRARY="$INSTALL_DIR/tcl8.6"
export TK_LIBRARY="$INSTALL_DIR/tk8.6"
exec "$VENV_DIR/bin/python" "$INSTALL_DIR/VideOCR.py" "\$@"
EOF
chmod +x "$HOME/.local/bin/videocr-launcher"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=VideOCR
Comment=Extract subtitles from video using PaddleOCR
Exec=$HOME/.local/bin/videocr-launcher
Icon=videocr
Type=Application
Terminal=false
Categories=AudioVideo;Video;Utility;
Keywords=subtitle;ocr;video;extract;paddle;
StartupNotify=true
EOF

# İkonu kopyala
cp "$INSTALL_DIR/Installer/VideOCR.png" "$ICON_DIR/videocr.png" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Masaüstü kısayolu oluşturuldu"
echo ""

# 9. Başlatıcı betiği oluştur
echo -e "${BLUE}[9/10]${NC} Komut satırı başlatıcısı oluşturuluyor..."
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/videocr" << EOF
#!/bin/bash
export TCL_LIBRARY="$INSTALL_DIR/tcl8.6"
export TK_LIBRARY="$INSTALL_DIR/tk8.6"
"$VENV_DIR/bin/python" "$INSTALL_DIR/VideOCR.py" "\$@"
EOF

chmod +x "$HOME/.local/bin/videocr"

echo -e "${GREEN}✓${NC} Başlatıcı oluşturuldu"
echo ""

# 10. PATH kontrolü
echo -e "${BLUE}[10/10]${NC} PATH yapılandırması kontrol ediliyor..."
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}⚠${NC} ~/.local/bin PATH'de değil"
    echo "   Lütfen ~/.bashrc veya ~/.config/fish/config.fish dosyasına ekleyin:"
    echo '   export PATH="$HOME/.local/bin:$PATH"'
else
    echo -e "${GREEN}✓${NC} PATH yapılandırması tamam"
fi
echo ""

# Kurulum tamamlandı
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           🎉 Kurulum Tamamlandı! 🎉                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📁 Kurulum Konumu:${NC} $INSTALL_DIR"
echo ""
echo -e "${BLUE}🚀 Kullanım:${NC}"
echo "   • GUI: videocr (komut satırından)"
echo "   • veya uygulama menüsünden 'VideOCR'"
echo "   • CLI: $INSTALL_DIR/videocr-cli.bin --help"
echo ""
echo -e "${YELLOW}💡 Not:${NC} İlk çalıştırmada PaddleOCR modelleri indirilecek"
echo "          (birkaç dakika sürebilir)"
echo ""
echo -e "${YELLOW}🔄 KDE/GNOME menüsünü yenilemek için:${NC}"
echo "   kbuildsycoca5 2>/dev/null || update-desktop-database ~/.local/share/applications"
