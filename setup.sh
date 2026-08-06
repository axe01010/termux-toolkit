#!/usr/bin/env bash
#
# termux-toolkit — setup.sh
#
# Idempotent bootstrap for a rich, sane Termux (dev-on-Android) working
# environment: package install, shared storage, dotfiles, scripts and
# (optional) fonts. Safe to run repeatedly.
#
#   bash setup.sh                     # standard profile
#   bash setup.sh --minimal           # packages only, no dotfiles
#   bash setup.sh --full --backup      # everything + a config backup first
#   bash setup.sh --dry-run            # show the plan, change nothing
#   bash setup.sh --help
#
set -euo pipefail

# ---------------------------------------------------------------- helpers
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_DIR="$REPO_ROOT/configs"
SCRIPT_DIR="$REPO_ROOT/scripts"
BACKUP_DIR="$HOME/.termux-toolkit-backup"
MARK_FILE="$HOME/.termux-toolkit-installed"

if [[ -t 1 ]]; then
    C_RESET=$'\e[0m'; C_DIM=$'\e[2m'
    C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'; C_CYAN=$'\e[36m'
else
    C_RESET=""; C_DIM=""; C_GREEN=""; C_YELLOW=""; C_CYAN=""
fi

log()  { printf '%s%s%s\n' "$C_CYAN" "$*" "$C_RESET"; }
ok()   { printf '%s[ ok ]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
info() { printf '%s[ .. ]%s %s\n' "$C_DIM" "$C_RESET" "$*"; }
warn() { printf '%s[ !! ]%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf '%s[ XX ]%s %s\n' "$C_RESET" "$*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------- defaults
PROFILE="standard"          # standard | minimal | full
DOTFILES=1
DO_BACKUP=0
DRY_RUN=0

# ---------------------------------------------------------------- options
usage() {
    cat <<'EOF'
termux-toolkit setup — idempotent Termux bootstrap

options:
  --minimal    packages only (no dotfiles)
  --full       standard + fonts
  --backup     back up existing dotfiles before overwriting
  --dry-run    show the plan, change nothing
  -h, --help   this message
EOF
}
while (($#)); do
    case "$1" in
        --minimal) PROFILE="minimal" ;;
        --full)    PROFILE="full" ;;
        --backup)  DO_BACKUP=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help) usage; exit 0 ;;
        *) warn "ignoring unknown option: $1" ;;
    esac
    shift
done

PM=""
if has pkg; then PM="pkg"; elif has apt-get; then PM="apt-get"; fi
[[ "$PM" != "" ]] || die "no package manager found (pkg/apt-get). Are you in Termux?"

# Build the plan under dry-run; execute otherwise.
run() {
    if ((DRY_RUN)); then printf '      %s\n' "$*"; return 0; fi
    "$@"
}

# ---------------------------------------------------------------- packages
BASE_PKGS=(git zsh tmux openssh python nodejs-lts fzf ripgrep tree jq htop openssl curl nano)
EXTRA_PKGS=(neovim bat exa duf)

packages() {
    log "== packages (via $PM) =="
    local pkgs=("${BASE_PKGS[@]}")
    [[ "$PROFILE" != "minimal" ]] && pkgs+=("${EXTRA_PKGS[@]}")
    info "target: ${pkgs[*]}"
    if ((DRY_RUN)); then
        run "$PM" install -y "${pkgs[@]}"
        return 0
    fi
    if [[ "$PM" == "pkg" ]]; then
        pkg update -y || warn "'pkg update' failed — continuing"
        pkg install -y "${pkgs[@]}" || warn "some packages failed"
    else
        sudo apt-get update -y || warn "'apt-get update' failed"
        sudo apt-get install -y "${pkgs[@]}" || warn "some packages failed"
    fi
    ok "package layer"
}

# ---------------------------------------------------------------- storage
storage() {
    log "== shared storage =="
    if has termux-setup-storage; then
        run termux-setup-storage
        ok "storage (termux-setup-storage)"
    elif [[ -d "$HOME/storage" ]]; then
        ok "storage already set up"
    else
        warn "termux-setup-storage unavailable — skipping shared storage"
    fi
}

# ---------------------------------------------------------------- scripts
install_scripts() {
    log "== scripts (→ ~/bin) =="
    mkdir -p "$HOME/bin"
    local s base
    for s in "$SCRIPT_DIR"/*.sh; do
        [[ -f "$s" ]] || continue
        base="$(basename "$s" .sh)"
        if ((DRY_RUN)); then
            printf '      link %s -> ~/bin/%s\n' "$s" "$base"
        else
            chmod +x "$s" 2>/dev/null || true
            ln -sf "$s" "$HOME/bin/$base"
        fi
        ok "$base"
    done
}

# ---------------------------------------------------------------- dotfiles
_PUT_SRC="$CONFIG_DIR"
_PUT_DST="$HOME"
link_dotfile() {
    [[ "$DOTFILES" == 1 ]] || return 0
    local name="$1"
    local src="$CONFIG_DIR/$name" target="$HOME/$name"
    [[ -f "$src" ]] || { warn "missing $src — skipping"; return 0; }

    if [[ -e "$target" && ! -L "$target" ]]; then
        if ((DO_BACKUP)); then
            mkdir -p "$BACKUP_DIR"
            run cp -a "$target" "$BACKUP_DIR/${name}.$(date +%Y%m%d-%H%M%S)"
            info "backed up $name"
        fi
        run rm -f "$target"
    fi
    [[ -L "$target" ]] && run rm -f "$target"
    run ln -s "$src" "$target"
    ok "linked $name"
}

dotfiles() {
    log "== dotfiles =="
    link_dotfile ".zshrc"
    link_dotfile ".tmux.conf"
    local reload="$HOME/.zshrc"
    if ((!DRY_RUN)) && [[ -f "$reload" ]]; then
        : > /dev/null   # (reload happens on next shell)
    fi
}

mark_done() {
    [[ "$DRY_RUN" == 0 ]] && { : > "$MARK_FILE"; }
    echo
    ok "termux-toolkit ready [profile: $PROFILE]"
    log "try:  tt-info · tt-update · tt-backup"
}

# ---------------------------------------------------------------- main
log "termux-toolkit setup — profile: $PROFILE"
packages
storage
install_scripts
dotfiles
mark_done