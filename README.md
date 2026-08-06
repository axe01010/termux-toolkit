<p align="center">
  <img src="https://github.com/axe01010/termux-toolkit/raw/main/assets/banner.png" alt="termux-toolkit" width="100%" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/axe01010/termux-toolkit?style=for-the-badge&color=24292F&logo=github" />
  <img src="https://img.shields.io/github/forks/axe01010/termux-toolkit?style=for-the-badge&color=3DDC84&logo=github" />
  <img src="https://img.shields.io/github/license/axe01010/termux-toolkit?style=for-the-badge&color=24292F" />
  <img src="https://img.shields.io/github/last-commit/axe01010/termux-toolkit?style=for-the-badge&color=3DDC84" />
</p>

<div align="center">

# 🔧 termux-toolkit

**An idempotent Termux bootstrap: sane dotfiles, useful scripts, one-shot setup.**

`bash setup.sh` · `bash update.sh` · `bash backup.sh`

[Quickstart](#quickstart) · [Scripts](#scripts) · [Architecture](docs/architecture.md) ·
[Setup guide](docs/setup.md) · [License](#license)

</div>

---

## What it is

`termux-toolkit` turns a fresh Termux install into a comfortable
on-device dev environment in one command. It's **idempotent** — you can run it
a hundred times and it only changes what needs changing. It installs packages,
links your dotfiles, drops helper scripts into `~/bin`, and exposes three
verbs you can run forever:

```bash
bash setup.sh                 # build the environment (safe to re-run)
bash update.sh                # pull the latest toolkit + refresh packages
bash backup.sh                # snapshot config + package manifest
```

## Quickstart

```bash
git clone https://github.com/axe01010/termux-toolkit.git
cd termux-toolkit

# standard profile: packages + dotfiles + scripts
bash setup.sh

# lighter / heavier / safer
bash setup.sh --minimal       # packages only
bash setup.sh --full --backup # packages + fonts, backing up files first
bash setup.sh --dry-run       # show the plan without touching anything
```

After setup, from any shell:

```bash
tt              # device + terminal snapshot (battery/mem/disk)
tt-update       # update toolkit + packages
tt-backup       # snapshot your setup to ~/.termux-toolkit-backup
```

## What you get

**Packages** (standard profile)
`git zsh tmux openssh python nodejs-lts fzf ripgrep tree jq htop openssl curl nano`
plus `neovim bat exa duf`.

**Dotfiles** (symlinked into `~`)
- `configs/.zshrc` — friendly prompt, git-aware RPROMPT, `ls`/`ll`/`cat`/`grep`
  aliases, dev shortcuts (`gs`, `gc`, `gpp`, `mkvenv`).
- `configs/.tmux.conf` — `C-a` prefix, vi mode, mouse, readable status bar.

**Scripts** (`~/bin`, symlinked from `scripts/`)
- `ttyinfo` — system / battery / memory / disk snapshot.
- `info` — the same plus toolkit revision + local-change count.

## Scripts

```bash
bash setup.sh --dry-run     # print everything before it happens
bash update.sh --no-pkgs    # only refresh toolkit files, skip package upgrade
bash backup.sh              # create ~/.termux-toolkit-backup/STAMP/
bash backup.sh --restore <stamp>   # bring back a prior snapshot
```

## Architecture

```
termux-toolkit/
├── setup.sh          # idempotent bootstrap (builds everything)
├── update.sh         # git pull + package upgrade + re-apply
├── backup.sh         # snapshot / restore
├── configs/          # .zshrc, .tmux.conf (symlinked into ~)
├── scripts/          # info.sh, ttyinfo.sh (symlinked into ~/bin)
└── docs/             # architecture, setup, usage
```

`setup.sh` is the dependency hub: it calls the package layer, the storage
layer, the script installer and the dotfile linker — each idempotent and
isolated. See **[docs/architecture.md](docs/architecture.md)** for detail.

## Use cases

- **Fresh Termux, fast** — one command, sane defaults.
- **Reproducible setups** — symlinks mean your dotfiles live in git, not
  copies scattered on disk; `backup.sh --restore` recovers them.
- **On-device dev without a laptop** — a tight tmux + zsh + fzf + bat core that
  fits a phone keyboard and screen.

## FAQ

| Q | A |
| - | - |
| Is it destructive? | No — it only symlinks if absent, backs up real files (`--backup`), and `--dry-run` shows the whole plan first. |
| What does it touch outside the repo? | `~/bin`, your dotfiles, the package DB, and your shared storage (only via `termux-setup-storage`). |
| Can I skip zsh/tmux? | Use `--minimal` (packages only) or edit `setup.sh`'s package array. |
| Does it require root? | No (`pkg` runs unprivileged; only `apt` mode uses `sudo`). |

## Contributing

Add scripts under `scripts/`, dotfiles under `configs/`, new package layers in
`setup.sh`. Keep everything idempotent and dry-run-safe — run
`bash setup.sh --dry-run` before and after your change. See
[docs/contributing](docs/usage.md).

## License

MIT — see [LICENSE](LICENSE).