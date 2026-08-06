#!/usr/bin/env bash
set -euo pipefail

echo "== Termux Toolkit setup =="
pkg update -y
pkg install -y git python nodejs neovim tmux zsh eza bat starship

echo "== link dotfiles =="
ln -sf "$PWD/configs/.zshrc" "$HOME/.zshrc"  || true
ln -sf "$PWD/configs/.tmux.conf" "$HOME/.tmux.conf" || true

echo "Done. Run 'zsh' to switch to the configured shell."