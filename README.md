# 🛠️ Termux Toolkit

<p align="center">
  <img src="https://img.shields.io/badge/Termux-Toolkit-black?style=for-the-badge&logo=linux&logoColor=white" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
</p>

> **Ultimate Termux productivity toolkit.** Transform your Android into a full dev environment.

## ✨ Features

- 🐧 Ubuntu/Debian proot setup
- 💻 Neovim, Tmux, Zsh pre-configured
- 🐳 Docker rootless (via podman)
- 🔧 Git, SSH, Python, Node, Go ready
- 📦 50+ CLI tools pre-installed
- 🎨 Catppuccin theme everywhere

## 🚀 Quick Start

```bash
git clone https://github.com/axe01010/termux-toolkit.git
cd termux-toolkit
bash setup.sh
```

## 📋 What Gets Installed

| Category | Tools |
|----------|-------|
| 🐧 OS | Ubuntu 22.04 proot |
| 💻 Editors | Neovim, Micro, Helix |
| 🔧 Dev | Git, Python, Node, Go, Rust |
| 📦 Ops | Docker, kubectl, terraform |
| 🎨 UI | Tmux, Zsh, Starship, eza, bat |

## 📁 Structure

```
termux-toolkit/
├── setup.sh              # One-command setup
├── configs/              # Dotfiles
│   ├── nvim/
│   ├── tmux/
│   └── zsh/
├── scripts/              # Utility scripts
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📜 License

MIT
