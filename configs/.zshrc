# ============================================================================
# termux-toolkit — .zshrc
# A lean-but-comfortable prompt + aliases for on-device dev.
# Load this via: ln -s $PWD/configs/.zshrc ~/.zshrc  (or let setup.sh do it)
# ============================================================================

# --- prompt --------------------------------------------------------------
autoload -Uz promptinit; promptinit
PROMPT='%F{green}%n@%m%f %F{blue}%~%f %F{magenta}$ %f'
# git branch in right prompt (if in a repo)
if git rev-parse 2>/dev/null; then
  RPROMPT='%(?.%F{cyan}✓.%F{red}✗)%f %F{yellow}$(git_current_branch 2>/dev/null)%f'
fi

# --- history -------------------------------------------------------------
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

# --- tools: ls/bat/eza -------------------------------------------------------
# eza (with icons) if present, else a clean plain-ls fallback
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons'
  alias ll='eza -lah --group-directories-first --icons'
else
  alias ls='ls --color=auto -A'
  alias ll='ls --color=auto -lh'
fi
alias cat='bat'
alias grep='rg --colors=always'
alias tree='tree -aC --dirsfirst'

# --- navigation + shortcuts -------------------------------------------------
alias ..='cd ..'
alias ...='cd ../../'
alias ~='cd ' ~2
alias homedir='cd $HOME'
alias repo='cd /data/data/com.termux/files/home/.hermes/polish/termux-toolkit'
alias pkg_help='termux-change-repo 2>/dev/null || echo "use pkg update"'
alias mkvenv='python -m venv .venv && source .venv/bin/activate'

# --- developer helpers ------------------------------------------------------
alias gs='git status -sb'
alias ga='git add -A'
alias gc='git commit -m'
alias gl='git log --oneline --graph --decorate -12'
alias gpp='git pull --ff-only && git push'
alias ip='ip -4 a 2>/dev/null | grep inet || hostname -I'

# --- on-device helpers -------------------------------------------------------
alias storage='cd ~/storage'   # after termux-setup-storage
alias battery='cat /sys/class/power_supply/battery/capacity 2>/dev/null; echo "%"'
alias meminfo='free -h'
alias tt='~/bin/ttyinfo'
alias tt-update='bash ~/bin/update 2>/dev/null || bash update.sh'
alias tt-backup='bash ~/bin/backup 2>/dev/null || bash backup.sh'

# --- showcase a tool on first run -------------------------------------------
if [[ -f ~/.termux-toolkit-installed ]] && [[ ! -f ~/.termux-toolkit-greeting ]]; then
  print -P '%F{cyan}termux-toolkit %f ready — try %F{green}tt%f, %F{green}tt-update%f'
  touch ~/.termux-toolkit-greeting
fi