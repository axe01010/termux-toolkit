# Usage — termux-toolkit

The day-to-day verbs and what they do.

## The three verbs

| Command              | When                          | What it does                                            |
| -------------------- | ----------------------------- | ------------------------------------------------------- |
| `bash setup.sh`      | first time / recreating env  | installs packages, links dotfiles, installs scripts     |
| `bash update.sh`     | routine                        | pulls this repo + updates packages + re-applies idempotently |
| `bash backup.sh`     | before a risky change         | snapshots dotfiles + package manifest into timed backup |

They're designed to be rerun freely — setup and update never clobber your
existing dotfiles (existing files are backed up, never overwritten blindly).

## setup.sh options

```bash
bash setup.sh                     # standard profile
bash setup.sh --full              # also installs neovim, bat, eza, exa·duf
bash setup.sh --minimal           # base packages + dotfiles only
bash setup.sh --no-dotfiles       # skip the .zshrc/.tmux.conf symlinks
bash setup.sh --backup            # snapshot before touching anything
bash setup.sh --dry-run           # print the plan, change nothing
```

Run `bash setup.sh --help` for the full list. On Termux a terminal reboot
(re-login) is recommended afterward so the new aliases/PATH take effect.

## update.sh

```bash
bash update.sh                    # pull repo + pkg upgrade + idempotent re-apply
```

It's safe on a fresh machine too (it works from a clean checkout).

## backup.sh

```bash
bash backup.sh                            # snapshot to ~/.termux-toolkit-backup
bash backup.sh --restore                    # pick the newest snapshot + restore
```

Each snapshot is a timestamped folder containing your dotfiles and a
`packages.txt` manifest (via `pkg list-installed` or `apt list --installed`).

## What ships in the toolbox

- `scripts/ttyinfo.sh`, `scripts/info.sh` — one-screen device + terminal status.
- `configs/.zshrc`, `configs/.tmux.conf` — the dotfiles setup symlinks into
  your `$HOME`. Add your own to `configs/` and they'll be linked on the next
  idempotent run.

## Troubleshooting

| Symptom | Fix |
| ------- | --- |
| `pkg: command not found` | you're not in Termux — run with `apt-get` mode or install Termux. |
| dotfiles not applied | run `bash setup.sh --no-dotfiles=false` or re-login after a `--minimal` pass. |
| `setup.sh` refuses to rerun | it's idempotent; if something looks odd, `bash backup.sh` then `bash setup.sh --full`. |
| some readings show `n/a` | `ttyinfo` reports best-effort; missing sysfs nodes just print `n/a`.