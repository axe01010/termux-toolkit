#!/usr/bin/env bash
#
# termux-toolkit — backup.sh
#
# Snapshot your on-device setup (dotfiles + installed-package manifest +
# toolkit revision) into ~/.termux-toolkit-backup. Non-destructive and
# timestamped. Restore a stamp later with:
#   bash backup.sh --restore <stamp>
#
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DEST="${HOME}/.termux-toolkit-backup"
NOW="$(date +%Y%m%d-%H%M%S)"
STAMP_DIR="$DEST/$NOW"

c_reset=$'\e[0m'; c_cy=$'\e[36m'; c_gr=$'\e[32m'
log() { printf '%s[ ok ]%s %s\n' "$c_cy" "$c_reset" "$*"; }
warn() { printf '%s[ !! ]%s %s\n' "$c_reset" "$*" >&2; }

restore() {
    local stamp="${1:-}"
    if [[ -z "$stamp" ]]; then
        printf '    recent backups:\n'
        ls -1t "$DEST" 2>/dev/null | head -5 || true
        return 1
    fi
    local src="$DEST/$stamp"
    [[ -d "$src" ]] || { printf 'backup not found: %s\n' "$src" >&2; return 1; }
    for f in .zshrc .tmux.conf; do
        if [[ -f "$src/$f" ]]; then
            cp "$src/$f" "$HOME/$f" && log "restored $f"
        fi
    done
    printf 'restored %s\n' "$stamp"
}

if [[ "${1:-}" == "--restore" ]]; then
    shift
    restore "${1:-}"
    exit 0
fi

mkdir -p "$STAMP_DIR"
printf 'backing up to %s\n' "$STAMP_DIR"

# 1) dotfiles (follow the toolkit symlinks so we save the *content*)
for f in .zshrc .tmux.conf; do
    if [[ -L "$HOME/$f" ]]; then
        cp -L "$HOME/$f" "$STAMP_DIR/$f" && log "dotfile $f"
    elif [[ -f "$HOME/$f" ]]; then
        cp "$HOME/$f" "$STAMP_DIR/$f" && log "dotfile $f"
    fi
done

# 2) package manifest
if command -v dpkg >/dev/null 2>&1; then
    dpkg-query -W -f='${Package} ${Version}\n' > "$STAMP_DIR/packages.txt" 2>/dev/null \
        && log "packages manifest ($(wc -l < "$STAMP_DIR/packages.txt") pkgs)"
else
    { command -v pkg >/dev/null 2>&1 && pkg list-installed 2>/dev/null || true; } \
        > "$STAMP_DIR/packages.txt"
    log "packages manifest (best-effort)"
fi

# 3) toolkit revision for reproducibility
if [[ -d "$REPO_ROOT/.git" ]] && command -v git >/dev/null 2>&1; then
    git -C "$REPO_ROOT" rev-parse HEAD > "$STAMP_DIR/kit-rev.txt" 2>/dev/null \
        && log "toolkit revision recorded"
fi

echo
printf 'backup complete: %s\n' "$STAMP_DIR"
printf 'restore later:   bash backup.sh --restore %s\n' "$NOW"
exit 0