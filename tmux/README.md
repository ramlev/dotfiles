# tmux

Personal tmux configuration. Stow package — `tmux.conf` is symlinked to
`~/.config/tmux/tmux.conf`.

## Install

```sh
cd ~/.dotfiles
stow -t "$HOME" tmux

git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux                       # start a server
# then: prefix + I         (install plugins)
```

Plugins live in `~/.config/tmux/plugins/` and are deliberately **not** tracked
in this repo. Only `tmux.conf` is.

## Keys

Prefix is <kbd>Ctrl</kbd>+<kbd>a</kbd>. Below, `prefix` means press it first.
Press <kbd>Ctrl</kbd>+<kbd>a</kbd> twice to send a literal `C-a` to the shell.

### Windows and panes

| Key | Action |
| --- | --- |
| `prefix` `\|` | Split vertically (side by side) |
| `prefix` `-` | Split horizontally (stacked) |
| `prefix` `c` | New window |
| `prefix` `a` | Last window |
| `prefix` `m` / `z` | Toggle pane zoom |
| `prefix` `H` `J` `K` `L` | Resize pane (repeatable — keep tapping) |
| `Ctrl`+`h/j/k/l` | Move between panes, **no prefix** |

Splits and new windows inherit the current pane's working directory.

`Ctrl`+`h/j/k/l` is `vim-tmux-navigator`. It detects whether the pane is running
vim/nvim/fzf and forwards the key there instead of switching panes, so the same
four keys move through nvim splits and tmux panes seamlessly.

> **Not fully wired yet.** The tmux half is installed; the nvim half is not. Add
> `christoomey/vim-tmux-navigator` to your lazy.nvim specs, or these keys will
> move panes from a shell but do nothing useful inside nvim.

### Copy mode

vi keys. `prefix` `[` enters copy mode, `q` leaves.

| Key | Action |
| --- | --- |
| `v` | Begin selection |
| `Ctrl`+`v` | Toggle rectangle/block selection |
| `y` | Copy to macOS clipboard and exit |

Mouse is on: drag to select, scroll to scroll back.

### Popups

| Key | Action |
| --- | --- |
| `prefix` `p` | Floating scratch shell — toggle open/closed |
| `prefix` `P` | Floax menu (resize, full-screen, close) |
| `prefix` `g` | lazygit, 90%×90%, in the pane's cwd |

The floating shell is `tmux-floax`, not a native popup. It is backed by a real
tmux session named `scratch`, so it **persists**: start a long command, hit
`prefix` `p` to pop out, keep working, then `prefix` `p` back in and it is still
running with its scrollback intact. A native `display-popup -E` would spawn a
fresh shell each time and kill it on exit.

It opens in the current pane's directory (`@floax-change-path`).

> `prefix` `p` overrides tmux's default `previous-window`. Use `prefix` `a` for
> last-window, or `prefix` `n` / number keys to move around.

### Config and plugins

| Key | Action |
| --- | --- |
| `prefix` `r` | Reload config |
| `prefix` `R` | Reload config (bound by tmux-sensible) |
| `prefix` `I` | Install plugins (tpm) |
| `prefix` `U` | Update plugins (tpm) |

## Plugins

| Plugin | Purpose |
| --- | --- |
| `tpm` | Plugin manager |
| `tmux-sensible` | Baseline defaults |
| `tmux-yank` | System clipboard integration |
| `vim-tmux-navigator` | Seamless pane/split navigation |
| `tmux-floax` | Persistent floating scratch shell |
| `catppuccin/tmux` | Status bar theme (mocha) |

On startup floax prints a burst of `unknown variable: FLOAX_*` messages. That is
the plugin probing its own environment variables before it sets them. Harmless,
and they are gone by the time the server finishes loading.

The `scratch` session shows up in `tmux ls` and in session pickers. It is created
lazily on first `prefix` `p`.

### Sessions do not survive reboots

There is no session save/restore. Sessions live only as long as the tmux server;
kill the server or reboot and they are gone.

## Status bar

catppuccin, `mocha` flavor, rounded separators. Right side, in order: current
directory, session name, hostname, date and time. Window numbers sit to the
right of the window name; the active window shows a zoom glyph when zoomed.

Requires a Nerd Font for the glyphs. iTerm2 is set to Hack Nerd Font.

### Notes if you edit the theme

Two things that will silently produce a broken bar:

**The `run` path.** Under tpm the plugin directory is named after the repo, so it
is `plugins/tmux/catppuccin.tmux` — *not* `plugins/catppuccin/tmux/...` as most of
the upstream README shows. Catppuccin must be `run` before any
`@catppuccin_status_*` module is referenced, which is why that `run` line sits
above the `status-right` block and above tpm's own `run`.

**Do not add `-F` to the module lines.** `set -agF` expands the format at config-load
time, when there is no pane or session context. `@catppuccin_status_directory` and
`@catppuccin_status_session` collapse to empty strings and get baked in — the bar
renders with only the host and clock, and nothing errors. Use plain `set -ag`.
`-F` is only correct for modules that interpolate variables owned by *other*
plugins, such as `cpu` and `battery`.

### Changing flavor

```tmux
set -g @catppuccin_flavor 'mocha'   # latte, frappe, macchiato, mocha
```

Note that nvim currently uses tokyonight, so the bar and the editor are on
different palettes. They coexist, but mocha's base (`#1e1e2e`) is not
tokyonight-night's (`#1a1b26`).

## Terminal

`tmux-256color` with truecolor (`RGB`) and undercurl (`usstyle`) advertised via
`terminal-features`, plus `allow-passthrough on` so nvim can emit OSC sequences
(image protocols, clipboard) through tmux.
