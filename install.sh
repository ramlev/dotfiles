#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step() { echo ""; echo -e "${BLUE}➜${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo ""
echo "Install dotfiles"
echo ""

read -p "Continue? (y/n) " -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    step "Cancelled"
    echo ""
    exit 0
fi

if [ ! -f ~/.hushlogin ]; then
    touch .hushlogin
fi

echo ""

# Git configuration
step "Configuring Git"
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/.global-gitignore ~/.global-gitignore
success "Git configured"

if ! command -v brew &>/dev/null; then
    step "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew installed"
fi

if [ ! -d ~/.oh-my-zsh ]; then
    step "Installing Oh My Zsh"
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended || warn "Oh My Zsh installation failed"
    success "Oh My Zsh installed"
fi

if [ -d ~/.dotfiles/Brewfile ]; then
    step "Installing packages from Brewfile"
    brew bundle --file=~/.dotfiles/Brewfile || warn "Some packages failed (likely already installed)"
    success "Brewfile processed"
if
