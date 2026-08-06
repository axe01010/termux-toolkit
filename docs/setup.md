# Setup — termux-toolkit

Everything you need to get the toolkit on a real device.

## Complete install (from scratch)

```bash
# 1) prerequisites (Termux app + storage)
termux-setup-storage            # allows file access (optional but recommended)

# 2) get the toolkit
git clone https://github.com/axe01010/termux-toolkit.git
cd termux-toolkit

# 3) run setup — standard profile
bash setup.sh

# 4) check what you got
tt
```

## Profiles & options

| Flag | Effect |
| ---- | ------ |
| *(default)* | Standard: packages + dotfiles + scripts. |
| `--minimal` | Packages only — no dotfiles/scripts. |
| `--full` | Standard + fonts (added to package list). |
| `--backup` | Back up existing dotfiles before linking over them. |
| `--dry-run` | Print the entire plan, change nothing. |
| `-h` / `--help` | Usage. |

Safe combo for the first run on a machine you care about:

```bash
bash setup.sh --backup --dry-run   # inspect
bash setup.sh --backup             # install, keeping a snapshot
```

## What setup.sh modifies

- Installs packages (git, zsh, tmux, ...).
- Creates `~/bin` and symlinks every `scripts/*.sh` there (`ttinfo` → `ttyinfo-sh`'s basename, etc.).
- Symlinks `configs/.zshrc` → `~/.zshrc` and `configs/.tmux.conf` → `~/.tmux.conf`.
- Writes `~/.termux-toolkit-installed`.
- May call `termux-setup-storage` (shared storage permission).

It does **not** change your default shell to zsh automatically — switch with
`chsh -s zsh` if you want that.

## Switching to zsh

```bash
pkg install zsh   # if not present
chsh -s zsh
# re-open the terminal; your .zshrc (from the toolkit) will load
```

## After setup

```bash
tt                # device snapshot
tt-update         # future updates
tt-backup         # periodic snapshots

# new shell aliases from .zshrc
gs   ; gc "message"   ; mkvenv   ; storage
```

## Troubleshooting

| Symptom | Fix |
| ------- | --- |
| `pkg: command not found` | You're not on Termux; the script falls back to `apt-get`. |
| `termux-setup-storage` not found | old Termux — `pkg install termux-tools`. |
| battery shows "(no /sys node)" | normal on this device/kernel; readings are best-effort. |
| aliases missing | ensure `~/.zshrc` exists and you're using zsh; `bash -rcfile ~/.zshrc` works too. |
| dotfile not linked | run `bash setup --minimal` …` to re-apply. |

For everything else, `docs/usage` explains the day-to-day commands.