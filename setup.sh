#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# TODO put package installation into its own script
# TODO add packages: nvim, fly, vercel, gh, keyd (from github), awscli, mongosh, btop, htop?
# TODO configure keyd (probably like tmux, bash etc )

# Packages to install via dnf
DNF_PACKAGES=(
    "xclip"
    "golang"
    "thunderbird"
    "goplease" # correct name?
)

# NPM packages to install globally
NPM_PACKAGES=(
    "@anthropics/claude-cli"
)

# Install packages via dnf
echo "Installing packages via dnf..."
for package in "${DNF_PACKAGES[@]}"; do
    if ! rpm -qa | grep -q "^$package"; then
        echo -e "${YELLOW}Installing $package...${NC}"
        sudo dnf install -y "$package"
    else
        echo -e "${GREEN}$package is already installed${NC}"
    fi
done

# Install npm packages globally
echo "Installing npm packages..."
for package in "${NPM_PACKAGES[@]}"; do
    # Extract package name for checking (removes @org/ prefix if present)
    check_name=$(echo "$package" | sed 's/@.*\///')
    if ! npm list -g --depth=0 2>/dev/null | grep -q "$package"; then
        echo -e "${YELLOW}Installing $package...${NC}"
        npm install -g "$package"
    else
        echo -e "${GREEN}$package is already installed${NC}"
    fi
done

# Install keyd from source
echo "Installing keyd..."
if ! command -v keyd &> /dev/null; then
    echo -e "${YELLOW}Installing keyd from source...${NC}"
    cd /tmp
    git clone https://github.com/rvaiya/keyd
    cd keyd
    make && sudo make install
    sudo systemctl enable --now keyd
    cd ~
    echo -e "${GREEN}keyd installed${NC}"
else
    echo -e "${GREEN}keyd is already installed${NC}"
fi

# Swap left-ctrl and left-alt - only works for Wayland on GNOME
# echo "Swapping left ctrl and left alt..."
# gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swap_lalt_lctl']"
# Commented this out because i'm doing it low level with keyd config now

echo "Setting up dotfiles..."

# Create config directory if it doesn't exist
mkdir -p ~/.config

# Backup existing configs if they exist
if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
    echo -e "${YELLOW}Backing up existing nvim config...${NC}"
    mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -d ~/.config/ghostty ] && [ ! -L ~/.config/ghostty ]; then
    echo -e "${YELLOW}Backing up existing ghostty config...${NC}"
    mv ~/.config/ghostty ~/.config/ghostty.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.bashrc ] && [ ! -L ~/.bashrc ]; then
    echo -e "${YELLOW}Backing up existing bashrc...${NC}"
    mv ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ]; then
    echo -e "${YELLOW}Backing up existing tmux config...${NC}"
    mv ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)
fi


# Using cp + rm instead of mv because sudo mv can have issues writing to user home directory
if [ -f /etc/keyd/default.conf ] && [ ! -L /etc/keyd/default.conf ]; then
    echo -e "${YELLOW}Backing up existing keyd config...${NC}"
    sudo cp /etc/keyd/default.conf ~/keyd.backup.$(date +%Y%m%d_%H%M%S)
    sudo rm /etc/keyd/default.conf
fi

# Create symlinks
echo "Creating symlinks..."
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/ghostty/ ~/.config/ghostty
ln -sf ~/dotfiles/bashrc ~/.bashrc
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
sudo mkdir -p /etc/keyd
sudo ln -sf ~/dotfiles/keyd/default.conf /etc/keyd/default.conf
sudo systemctl restart keyd

echo -e "${GREEN}✓ Dotfiles setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open nvim and run :Lazy install to install plugins"
echo "  2. Restart terminal for tmux changes to take effect"
