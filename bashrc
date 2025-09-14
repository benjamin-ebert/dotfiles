# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

alias xc='xclip -sel clipboard'
alias xclip='xclip -sel clipboard'
alias nv='nvim'
alias n='nvim'
alias l='ls -lah'
alias s='git status'

# Ghostty theme switching
light() {
    sed -i '66s/^# *//' ~/dotfiles/ghostty/config  # uncomment light theme
    sed -i '78s/^/# /' ~/dotfiles/ghostty/config   # comment dark theme
    # kill -SIGUSR2 $(pgrep ghostty) 2>/dev/null || echo "Switched to light theme (restart Ghostty if needed)"
    echo "Switched to light theme - restart config by pressing Ctrl+Shift+,"
}

dark() {
    sed -i '66s/^/# /' ~/dotfiles/ghostty/config   # comment light theme
    sed -i '78s/^# *//' ~/dotfiles/ghostty/config  # uncomment dark theme
    # kill -SIGUSR2 $(pgrep ghostty) 2>/dev/null || echo "Switched to dark theme (restart Ghostty if needed)"
    echo "Switched to dark theme - restart config by pressing Ctrl+Shift+,"
}

# Only run fastfetch in interactive terminals, not when Claude runs commands
if [ -z "$CLAUDECODE" ]; then
    fastfetch
fi
