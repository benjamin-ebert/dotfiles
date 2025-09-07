# Dotfiles

Personal configuration files for development environment.

## What's Included
- **Neovim**: Lightweight IDE setup with LSP, Telescope, autocompletion, and smart commenting
- **Tmux**: Terminal multiplexer configuration (if present)

## Installation

```bash
git clone git@github.com:benjamin-ebert/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## What the Setup Script Does

The `setup.sh` script will:
1. Backup any existing configs with timestamps (e.g., `nvim.backup.20250107_143022`)
2. Create symlinks from `~/.config/nvim` to `~/dotfiles/nvim`
3. Create symlinks from `~/.tmux.conf` to `~/dotfiles/tmux.conf`
4. Provide clear status messages during setup

After running setup:
1. Open Neovim and run `:Lazy install` to install plugins
2. Restart your terminal for tmux changes to take effect

## Manual Installation

If you prefer manual setup:
```bash
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
