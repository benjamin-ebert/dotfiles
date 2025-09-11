#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Setting up dotfiles..."

# Create config directory if it doesn't exist
mkdir -p ~/.config

# Backup existing configs if they exist
if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
    echo -e "${YELLOW}Backing up existing nvim config...${NC}"
    mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.bashrc ] && [ ! -L ~/.bashrc ]; then
    echo -e "${YELLOW}Backing up existing bashrc...${NC}"
    mv ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ]; then
    echo -e "${YELLOW}Backing up existing tmux config...${NC}"
    mv ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)
fi

# Create symlinks
echo "Creating symlinks..."
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/bashrc ~/.bashrc
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf

echo -e "${GREEN}✓ Dotfiles setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open nvim and run :Lazy install to install plugins"
echo "  2. Restart terminal for tmux changes to take effect"
