# Ghostty

TokyoNight Night theme, MesloLGS Nerd Font Mono, Danish keyboard tweaks. Stow package:
symlinked to `~/.config/ghostty/config`.

## Install

```sh
brew install --cask ghostty font-meslo-lg-nerd-font
cd ~/.dotfiles && stow ghostty
```

The quick terminal hotkey needs Ghostty allowed under System Settings → Privacy
& Security → Accessibility.

## Setup notes

- **Theme:** always dark TokyoNight Night, 95% opacity with blur.
- **Option keys:** left Option types Danish characters (`@ £ $ | \ { } [ ]`).
  Right Option acts as Alt/Meta for the shell, tmux and nvim.
- **Copy on select:** selecting text copies it to the clipboard.
- **Shell integration:** zsh, and Ghostty's terminfo is installed on SSH hosts.

## Cheatsheet

`⌘` = Cmd, `⌃` = Ctrl, `⌥` = Option, `⇧` = Shift.

### Windows and tabs

| Key | Action |
| --- | --- |
| `⌘N` | New window |
| `⌘T` | New tab |
| `⌘1`–`⌘8` / `⌘9` | Go to tab / last tab |
| `⌃Tab` / `⌃⇧Tab` | Next / previous tab |
| `⌘W` | Close split or tab |
| `⌘⇧W` | Close window |
| `⌘Enter` | Toggle fullscreen |
| `⌃⌘T` | Quick terminal (global drop-down) |

### Splits

| Key | Action |
| --- | --- |
| `⌘D` | Split right |
| `⌘⇧D` | Split down |
| `⌃⌘H` `J` `K` `L` | Move to split |
| `⌃⌘⇧H` `J` `K` `L` | Resize split |
| `⌃⌘=` | Equalize splits |
| `⌃⌘Z` / `⌘⇧Enter` | Zoom split |

### Scroll and search

| Key | Action |
| --- | --- |
| `⌘F` | Search |
| `⌘G` / `⌘⇧G` | Next / previous match |
| `⌘↑` / `⌘↓` | Jump to previous / next prompt |
| `⌘Home` / `⌘End` | Scroll to top / bottom |
| `⌘K` | Clear screen |

### Font and config

| Key | Action |
| --- | --- |
| `⌘+` / `⌘-` / `⌘0` | Bigger / smaller / reset font |
| `⌘,` | Open config |
| `⌘⇧,` | Reload config |
| `⌘⇧P` | Command palette |
| `⌘⌥I` | Inspector |

See every binding with `ghostty +list-keybinds`, or every option with
`ghostty +show-config --default --docs`.
