#!/usr/bin/env bash
# ttyinfo — quick device + terminal snapshot
# (the original toolkit script, extended with best-effort battery/mem reads).
# Safe on Termux and plain Linux.
#
set -u

c_reset=$'\e[0m'; c_b=$'\e[1m'; c_cy=$'\e[36m'
cap() { printf '%s%s%s\n' "${c_b}${c_cy}" "$*" "$c_reset"; }

cap "system"
uname -a
echo "shell  : $SHELL"

if [[ -n "${TERMUX_VERSION:-}" ]]; then
    echo "termux : $TERMUX_VERSION"
fi
echo "prefix : ${PREFIX:-/usr}"
df -h "${PREFIX:-/}" 2>/dev/null | awk 'NR==2{print "disk   : " $4 " free on " $6}'

cap "battery"
if [[ -r /sys/class/power_supply/battery/capacity ]]; then
    pct=$(cat /sys/class/power_supply/battery/capacity)
    status=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "")
    echo "battery: ${pct}%${status:+ ($status)}"
else
    echo "battery: (no /sys battery node — desktop machine?)"
fi

cap "memory"
if command -v free >/dev/null 2>&1; then
    free -h
else
    awk '/MemTotal|MemFree/{printf "%s %6d kB\n", $1, $2}' /proc/meminfo 2>/dev/null \
        || echo "(no free or /proc/meminfo — try: pkg install procps)"
fi