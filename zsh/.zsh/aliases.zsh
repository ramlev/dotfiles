# PHP
alias phpunit="vendor/bin/phpunit"
alias c="claude"
alias cu="composer update"
alias cr="composer require"
alias ci="composer install"
alias cda="composer dump-autoload -o"
alias hostfile="sudo vi /etc/hosts"
alias nah='git reset --hard;git clean -df'
alias vim=nvim
alias v=vim
alias fff='fork $(git root)'
alias tower='gittower $(git root)'
alias sshconfig="vi ~/.ssh/config"
alias copykey='command cat ~/.ssh/id_ed25519.pub 2>/dev/null || command cat ~/.ssh/id_rsa.pub 2>/dev/null | pbcopy'

alias ddl="ddev launch"
alias ddls="ddev describe"

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
cx() { cd "$@" && l; }

# Git
alias gpo="git push origin"
alias push="git push"
alias ggpush='git push origin "$(git_current_branch)"'
alias gpoat="git push origin --all && git push origin --tags"
alias ggpull='git pull origin "$(git_current_branch)"'
alias pull="git pull"
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'
alias uncommit="git reset --soft HEAD~1"

# Fast open
alias o="open ."

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# PhpStorm
alias phpstorm='open -a ~/Applications/PhpStorm.app "`pwd`"'

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# IP addresses
alias ip="curl ifconfig.me/ip ; echo"
alias localip="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Flush Directory Service cache
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Modern CLI tool aliases (conditional on installation)
alias ls="eza --icons --group-directories-first"
alias l="eza -la --icons --group-directories-first --hyperlink"
alias ll="eza -l --icons --group-directories-first --hyperlink"
alias lt="eza --tree --level=2 --icons"
alias catp="bat --style=plain"
alias grep="rg"
