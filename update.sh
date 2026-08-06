#!/usr/bin/env bash
#
# termux-toolkit — update.sh
#
# Updates the toolkit itself plus the on-device package base, then re-applies
# idempotently. Safe to run repeatedly.
#   bash update.sh               # packages + re-apply dotfiles
#   bash update.sh --no-pkgs     # only refresh the toolkit files
#
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
NO_PKGS=0
[[ "${1:-}" == "--no-pkgs" ]] && NO_PKGS=1

c_reset=$'\e[0m'; c_cy=$'\e[36m'; c_gr=$'\e[32m'; c_ye=$'\e[33m'
log()  { printf '%s»%s %s\n' "$c_cy" "$c_reset" "$*"; }
ok()   { printf '%s[ ok ]%s %s\n' "$c_gr" "$c_reset" "$*"; }
warn() { printf '%s[ !! ]%s %s\n' "$c_ye" "$c_reset" "$*" >&2; }

log "updating termux-toolkit"

# 1) refresh the repo (if it's a git checkout)
if [[ -d "$REPO_ROOT/.git" ]] && command -v git >/dev/null 2>&1; then
    if git -C "$REPO_ROOT" pull --ff-only --quiet 2>/dev/null; then
        ok "repo updated"
    else
        warn "git pull failed — continuing with local files"
    fi
else
    info "not a git checkout — skipping pull"
fi

# 2) refresh packages unless told not to
if [[ "$NO_PKGS" == 0 ]]; then
    if command -v pkg >/dev/null 2>&1; then
        log "pkg update && upgrade"
        pkg update -y || warn "pkg update failed"
        pkg upgrade -y || warn "pkg upgrade failed"
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y || warn "apt-get update failed"
        sudo apt-get upgrade -y || warn "apt-get upgrade failed"
    fi
    ok "packages refreshed"
fi

# 3) re-apply config idempotently (only touches already-symlinked files)
log "re-applying dotfiles"
"$REPO_ROOT/setup.sh" --minimal >/dev/null 2>&1 || warn "setup re-apply had warnings"

ok "update complete"