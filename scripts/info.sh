#!/usr/bin/env bash
# info — one-screen "tt" device + environment summary for termux-toolkit.
# Thin wrapper around ttyinfo that adds repo status. Run from anywhere.
#
set -u
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"

bash "$HERE/scripts/ttyinfo.sh"

echo
printf 'toolkit : %s\n' "$HERE"
if [[ -d "$HERE/.git" ]] && command -v git >/dev/null 2>&1; then
    printf 'rev     : %s\n' "$(git -C "$HERE" rev-parse --short HEAD 2>/dev/null)"
    printf 'status  : %s\n' "$(git -C "$HERE" status --porcelain | wc -l) local change(s)"
fi