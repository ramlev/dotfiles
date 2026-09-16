# btop

Resource monitor with the TokyoNight Night theme. Stow package: symlinked to
`~/.config/btop/btop.conf`.

## Install

```sh
brew install btop
cd ~/.dotfiles && stow btop
```

## Setup notes

- **Theme:** `tokyo-night`, the theme that ships with btop
  (`/opt/homebrew/share/btop/themes/tokyo-night.theme`), so no theme file lives
  here. Set it by bare name, not by absolute path — btop writes a
  version-pinned Cellar path when you pick a theme from the options menu, and
  that breaks on the next `brew upgrade`.
- **Background:** `theme_background = false`, so Ghostty's background,
  opacity and blur show through.
- **Saved on exit:** `save_config_on_exit = true` means btop rewrites
  `btop.conf` when it quits. Changes made in the options menu (`o`) show up as
  a git diff.
- **Custom themes:** drop `.theme` files in `.config/btop/themes/`.

## Cheatsheet

| Key | Action |
| --- | --- |
| `m` / `Esc` | Menu |
| `o` | Options |
| `h` | Help |
| `1`–`4` | Toggle cpu / mem / net / proc boxes |
| `p` / `⇧P` | Next / previous layout preset |
| `f` | Filter processes |
| `←` / `→` | Change process sort column |
| `r` | Reverse sort |
| `e` | Tree view |
| `Enter` | Process details |
| `t` / `k` | Terminate / kill selected process |
| `q` | Quit |
