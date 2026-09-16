# tmux

omerxx-style tmux with a hand-rolled TokyoNight Night status bar. Stow package: symlinked to
`~/.config/tmux/`.

| File | Contents |
| --- | --- |
| `tmux.conf` | Options, TokyoNight palette, status bar, plugins |
| `tmux.reset.conf` | Keybindings (sourced first) |

## Install

```sh
cd ~/.dotfiles && stow tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux                # then: prefix + I
```

Plugins live in `~/.config/tmux/plugins/` and are git-ignored. tmux-thumbs needs
a one-time build: `cd ~/.config/tmux/plugins/tmux-thumbs && cargo build --release`.

## Cheatsheet

Prefix is `C-a`. Everything below is `prefix` then the key unless noted.

### Sessions

| Key | Action |
| --- | --- |
| `o` | Session picker (sessionx + zoxide) |
| `S` | Built-in session list |
| `C-d` | Detach |
| `C-s` / `C-r` | Save / restore sessions (resurrect) |

Inside sessionx: `ctrl-y` opens a zoxide dir as a new window. Sessions are
auto-saved and restored on start (continuum).

### Windows

| Key | Action |
| --- | --- |
| `C-c` | New window (in `$HOME`) |
| `H` / `L` | Previous / next window |
| `C-a` | Last window |
| `r` | Rename window |
| `w` | List windows |
| `"` | Choose window |

### Panes

| Key | Action |
| --- | --- |
| `s` | Split stacked |
| `v` | Split side by side |
| `\|` | Split stacked (no cwd) |
| `h` `j` `k` `l` | Move to pane |
| `,` `.` | Resize left / right (repeatable) |
| `-` `=` | Resize down / up (repeatable) |
| `z` | Zoom pane |
| `x` | Swap with next pane |
| `c` | **Kill pane** (no confirm) |
| `*` | Toggle synchronized input |
| `P` | Toggle pane titles |
| `K` | Clear the pane |

### Popups and pickers

| Key | Action |
| --- | --- |
| `p` | Floating persistent shell (floax) |
| `Space` | Hint-copy text on screen (thumbs) |
| `u` | Pick a URL to open (fzf-url) |
| `F` | tmux-fzf menu |

### Copy mode

`prefix [` to enter, `q` to leave. vi keys.

| Key | Action |
| --- | --- |
| `v` | Begin selection |
| `y` | Copy to system clipboard (yank) |

### Misc

| Key | Action |
| --- | --- |
| `R` | Reload config |
| `:` | Command prompt |
| `I` / `U` | Install / update plugins (tpm) |
| `C-x` | Lock server |

## Status bar

Top of the screen. Left: session (green, red while prefix is held). Middle:
windows as `name █N`, current one in frost blue, zoom icon when zoomed. Right:
current directory. Colors are `@tn_*` user options in `tmux.conf`.

Needs a Nerd Font (Ghostty uses MesloLGS Nerd Font Mono).
