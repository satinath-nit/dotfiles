#!/usr/bin/env bash
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

all=1
brew_flag=0
stow_flag=0
unstow_flag=0
shell_flag=0
nvim_flag=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    echo ""
    echo "Dotfiles Setup Script"
    echo "====================="
    echo ""
    echo "Usage: ./setup_env.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -a, --all       Run all setup steps (default if no flags)"
    echo "  -b, --brew      Install Homebrew packages from Brewfile"
    echo "  -s, --stow      Symlink dotfiles using GNU Stow"
    echo "  -u, --unstow    Remove symlinked dotfiles"
    echo "  -z, --shell     Install Oh My Zsh and shell plugins"
    echo "  -n, --nvim      Setup NeoVim plugins"
    echo ""
    echo "Examples:"
    echo "  ./setup_env.sh           # Run everything"
    echo "  ./setup_env.sh -b -s     # Only brew install and stow"
    echo "  ./setup_env.sh --unstow  # Remove all symlinks"
    echo ""
}

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        log_success "Homebrew installed"
    else
        log_success "Homebrew already installed"
    fi
}

brew_install() {
    install_homebrew

    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        log_info "Installing packages from Brewfile..."
        brew bundle --file="$DOTFILES_DIR/Brewfile" --force --no-lock
        log_success "Brew packages installed"
    else
        log_error "Brewfile not found at $DOTFILES_DIR/Brewfile"
        exit 1
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed"
    else
        log_success "Oh My Zsh already installed"
    fi
}

setup_shell() {
    install_oh_my_zsh

    log_info "Setting up fzf key bindings..."
    if command -v fzf &>/dev/null; then
        "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
        log_success "fzf configured"
    else
        log_warn "fzf not found, skipping fzf setup"
    fi
}

stow_files() {
    if ! command -v stow &>/dev/null; then
        log_error "GNU Stow is not installed. Run with -b first to install it."
        exit 1
    fi

    if [[ ! -L "$HOME/.zshrc" && -f "$HOME/.zshrc" ]]; then
        log_warn "Backing up existing ~/.zshrc to ~/.zshrc.bak"
        mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    fi

    if [[ ! -L "$HOME/.gitconfig" && -f "$HOME/.gitconfig" ]]; then
        log_warn "Backing up existing ~/.gitconfig to ~/.gitconfig.bak"
        mv "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
    fi

    if [[ ! -L "$HOME/.tmux.conf" && -f "$HOME/.tmux.conf" ]]; then
        log_warn "Backing up existing ~/.tmux.conf to ~/.tmux.conf.bak"
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
    fi

    log_info "Stowing dotfiles..."
    cd "$DOTFILES_DIR"
    stow . --restow --target="$HOME"
    log_success "Dotfiles stowed successfully"
}

unstow_files() {
    if ! command -v stow &>/dev/null; then
        log_error "GNU Stow is not installed."
        exit 1
    fi

    log_info "Unstowing dotfiles..."
    cd "$DOTFILES_DIR"
    stow -D . --target="$HOME"
    log_success "Dotfiles unstowed"
}

nvim_setup() {
    if ! command -v nvim &>/dev/null; then
        log_error "NeoVim is not installed. Run with -b first to install it."
        exit 1
    fi

    log_info "Setting up NeoVim plugins (this may take a moment)..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    log_success "NeoVim plugins installed"
}

while :; do
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--all)
            all=1
            ;;
        -b|--brew)
            brew_flag=1
            all=0
            ;;
        -s|--stow)
            stow_flag=1
            all=0
            ;;
        -u|--unstow)
            unstow_flag=1
            all=0
            ;;
        -z|--shell)
            shell_flag=1
            all=0
            ;;
        -n|--nvim)
            nvim_flag=1
            all=0
            ;;
        "")
            break
            ;;
        *)
            log_warn "Unknown option: $1"
            ;;
    esac
    shift
done

echo ""
echo "========================================="
echo "       Dotfiles Setup"
echo "========================================="
echo ""

if [[ $brew_flag -eq 1 ]] || [[ $all -eq 1 ]]; then
    brew_install
    echo ""
fi

if [[ $shell_flag -eq 1 ]] || [[ $all -eq 1 ]]; then
    setup_shell
    echo ""
fi

if [[ $unstow_flag -eq 1 ]]; then
    unstow_files
    echo ""
fi

if [[ $stow_flag -eq 1 ]] || [[ $all -eq 1 ]]; then
    stow_files
    echo ""
fi

if [[ $nvim_flag -eq 1 ]] || [[ $all -eq 1 ]]; then
    nvim_setup
    echo ""
fi

echo "========================================="
log_success "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Update ~/.gitconfig with your name and email"
echo "  2. Restart your terminal or run: source ~/.zshrc"
echo "  3. Open nvim to let plugins finish installing"
echo ""
echo "========================================="
