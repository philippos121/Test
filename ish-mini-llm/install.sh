#!/bin/sh
#
# MiniLLM Installer for iSH (Alpine Linux on iPhone)
#
# Usage:
#   sh install.sh           # Full install
#   sh install.sh --quick   # Skip llama-cpp-python compilation
#
# One-liner from GitHub:
#   apk add git && git clone https://github.com/YOUR_USER/Test.git && sh Test/ish-mini-llm/install.sh
#

set -e

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m'

echo ""
echo "${CYAN}=====================================${NC}"
echo "${CYAN}  MiniLLM Installer for iSH${NC}"
echo "${CYAN}=====================================${NC}"
echo ""

QUICK=0
if [ "$1" = "--quick" ]; then
    QUICK=1
    echo "${YELLOW}Quick mode: skipping llama-cpp-python compilation${NC}"
    echo ""
fi

# ----- Step 1: System packages -----
echo "${GREEN}[1/5] Installing system packages...${NC}"
apk update
apk add --no-cache \
    python3 \
    py3-pip \
    git \
    curl \
    wget \
    gcc \
    g++ \
    musl-dev \
    python3-dev \
    cmake \
    make \
    linux-headers

echo "${GREEN}  Done!${NC}"
echo ""

# ----- Step 2: Create directories -----
echo "${GREEN}[2/5] Setting up directories...${NC}"
mkdir -p ~/.minillm/models
mkdir -p ~/.minillm/datasets
mkdir -p ~/.minillm/adapters
mkdir -p ~/.minillm/history
echo "${GREEN}  Done!${NC}"
echo ""

# ----- Step 3: Install llama-cpp-python -----
if [ $QUICK -eq 0 ]; then
    echo "${GREEN}[3/5] Installing llama-cpp-python...${NC}"
    echo "${YELLOW}  This compiles llama.cpp from source.${NC}"
    echo "${YELLOW}  On iSH this can be slow -- be patient!${NC}"
    echo ""

    # Disable GPU features not available on iSH
    export CMAKE_ARGS="-DLLAMA_METAL=OFF -DLLAMA_CUDA=OFF -DLLAMA_OPENCL=OFF -DLLAMA_HIPBLAS=OFF -DLLAMA_VULKAN=OFF"
    export FORCE_CMAKE=1

    if pip3 install --break-system-packages llama-cpp-python 2>/dev/null; then
        echo "${GREEN}  llama-cpp-python installed!${NC}"
    elif pip3 install llama-cpp-python 2>/dev/null; then
        echo "${GREEN}  llama-cpp-python installed!${NC}"
    else
        echo "${RED}  llama-cpp-python compilation failed.${NC}"
        echo "${YELLOW}  You can retry later with: pip3 install llama-cpp-python${NC}"
        echo "${YELLOW}  The app will still work for model management and web UI.${NC}"
    fi
else
    echo "${YELLOW}[3/5] Skipping llama-cpp-python (quick mode)${NC}"
fi
echo ""

# ----- Step 4: Find our script directory -----
echo "${GREEN}[4/5] Setting up MiniLLM...${NC}"

# Detect where the install script is running from
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$SCRIPT_DIR/app.py" ]; then
    # Fallback: check if we're in the repo
    if [ -f "./ish-mini-llm/app.py" ]; then
        SCRIPT_DIR="$(pwd)/ish-mini-llm"
    elif [ -f "./app.py" ]; then
        SCRIPT_DIR="$(pwd)"
    else
        echo "${RED}  Cannot find MiniLLM files. Make sure you run this from the repo.${NC}"
        exit 1
    fi
fi

# Create a launcher symlink
cat > /usr/local/bin/minillm << LAUNCHER
#!/bin/sh
cd "$SCRIPT_DIR"
exec python3 app.py "\$@"
LAUNCHER
chmod +x /usr/local/bin/minillm

echo "${GREEN}  Installed 'minillm' command${NC}"
echo ""

# ----- Step 5: Verify -----
echo "${GREEN}[5/5] Verifying installation...${NC}"
echo ""

python3 -c "
import sys
print(f'  Python:       {sys.version.split()[0]}')
try:
    from llama_cpp import Llama
    print('  llama.cpp:    installed')
except ImportError:
    print('  llama.cpp:    NOT installed (inference will not work)')
print(f'  App dir:      $SCRIPT_DIR')
print(f'  Data dir:     ~/.minillm/')
print('  Command:      minillm')
"

echo ""
echo "${GREEN}=====================================${NC}"
echo "${GREEN}  Installation complete!${NC}"
echo "${GREEN}=====================================${NC}"
echo ""
echo "  Quick start:"
echo "    ${CYAN}minillm${NC}                    # Interactive mode"
echo "    ${CYAN}minillm models${NC}             # See available models"
echo "    ${CYAN}minillm download smollm-360m${NC}  # Download smallest model"
echo "    ${CYAN}minillm chat${NC}               # Start chatting"
echo "    ${CYAN}minillm server${NC}             # Start API + Web UI"
echo ""
echo "  Web UI: Open Safari and go to http://localhost:8080"
echo ""
echo "  Recommended first model: ${CYAN}smollm-360m${NC} (387 MB, fastest)"
echo "  Better quality:          ${CYAN}qwen2-1.5b${NC} (986 MB)"
echo ""
