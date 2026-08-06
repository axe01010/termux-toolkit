# Architecture — termux-toolkit

This document explains how the three commands fit together and the principles
that keep setup idempotent and safe.

## Layout

```
termux-toolkit/
├── setup.sh          # builds EVERYTHING (the dependency hub)
├── update.sh         # git pull → package upgrade → re-apply
├── backup.sh         # snapshot + --restore
├── configs/          # dotfiles (source of truth for ~/.zshrc, ~/.tmux.conf)
├── scripts/          # helper scripts (symlinked into ~/bin)
└── docs/
```

Two different "views" of the same tree matter:

- **The repo is source.** `configs/` holds the real, versioned dotfiles;
  `scripts/` holds the real scripts. `git` tracks *this* copy.
- **Your home dir is a facade.** `setup.sh` creates `~/.zshrc`,
  `~/.tmux.conf` and `~/bin/*` as *symlinks back into the repo*. So you edit
  once (here) and every shell/tmux sees the change — no copy drift.

## How `setup.sh` is organised

`setup.sh` is a sequence of isolated **layers**, each idempotent:

```
setup.sh
 ├─ options / profile   (standard | minimal | full; --backup; --dry-run)
 ├─ PM detect           (pkg on Termux, apt-get elsewhere)
 ├─ packages()          → BASE_PKGS + EXTRA_PKGS via the right manager
 ├─ storage()           → termux-setup-storage (shared storage)
 ├─ install_scripts()   → symlink scripts/*.sh into ~/bin
 ├─ dotfiles()          → link_dotfile() for .zshrc/.tmux.conf
 └─ mark_done()         → touch ~/.termux-toolkit-installed
```

### Idempotence, concretely

- `pkg install -y <pkgs>` is a no-op for already-installed packages.
- `link_dotfile()`: if the target exists and is a symlink it's skipped; a
  *real* file is only removed after `--backup` copies it away. A subsequent run
  changes nothing.
- `touch $MARK_FILE` only on non-dry runs.

### Dry-run safety

Every mutating call goes through `run()`, which prints the command and returns
when `--dry-run`. So `bash setup.sh --dry-run` shows the *entire plan* without
installing a single package or touching a dotfile — this is the CI/PR gate.

## How `update.sh` / `backup.sh` relate

- `update.sh` = **forward**: git pull the repo, then `pkg upgrade`, then
  `setup.sh --minimal` to re-apply symlinks (idempotent — it only replaces
  broken symlinks). `--no-pkgs` skips the package phase only.
- `backup.sh` = **backward**: copy dotfiles (following their link to capture
  content), dump a package manifest, record the toolkit revision — into a
  timestamped directory `~/.termux-toolkit-backup/STAMP/`. `--restore`
  copies the dotfiles back.

## Design principles

1. **Idempotent, twice.** The function of the toolkit can run any time, and
   re-running changes nothing.
2. **Symlink the facade.** Your dotfiles live in the repo; your home only
   points at them.
3. **Dry-run everywhere.** No body of work is unplanned.
4. **Best-effort readings.** `ttyinfo.sh` degrades gracefully when `/sys`,
   `free`, or battery nodes are absent (chromebooks, restricted Android
   sandboxes).
5. **Termux-first, Linux works too.** `pkg` is preferred, but `apt-get`
   mode keeps it useful outside Android.

## Extension points

- New script → drop it in `scripts/`; `setup.sh` auto-symlinks it to `~/bin`.
- New dotfile → `configs/` + one `link_dotfile` line.
- New package layer → edit `packages()` arrays.
- New profile → add a `--flag` case + branch in the shared layers.

Keep any addition idempotent and dry-run-safe — that's the contract.