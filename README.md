# Dotfiles

Personal development environment configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/) and [Homebrew](https://brew.sh/).

## What's Included

| File/Directory | Purpose |
|---|---|
| `Brewfile` | All CLI tools and macOS apps (Homebrew) |
| `.zshrc` | Zsh shell config with aliases, functions, and plugins |
| `.gitconfig` | Git defaults, aliases, and delta diff viewer |
| `.gitignore_global` | Global gitignore for all repos |
| `.tmux.conf` | Tmux config with vim keybindings and Catppuccin theme |
| `.config/nvim/` | NeoVim config with lazy.nvim, LSP, Treesitter, Telescope |
| `.config/starship.toml` | Starship prompt theme |
| `setup_env.sh` | Bootstrap script to set everything up |

## Quick Start (New Machine)

```bash
# 1. Clone this repo
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Make setup script executable
chmod +x setup_env.sh

# 3. Run the full setup
./setup_env.sh
```

This will:
- Install Homebrew (if not present)
- Install all packages from `Brewfile`
- Install Oh My Zsh
- Symlink all dotfiles to `$HOME` using GNU Stow
- Set up NeoVim plugins

## Selective Setup

You can run individual steps:

```bash
./setup_env.sh -b        # Only install Homebrew packages
./setup_env.sh -z        # Only install Oh My Zsh + shell plugins
./setup_env.sh -s        # Only symlink dotfiles (stow)
./setup_env.sh -n        # Only setup NeoVim
./setup_env.sh -u        # Remove all symlinks (unstow)
./setup_env.sh -h        # Show help
```

## After Setup

1. **Update your git identity:**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

3. **Open NeoVim** to let plugins finish installing:
   ```bash
   nvim
   ```

## Machine-Specific Config

For settings that differ per machine (work vs personal), create these files (they are git-ignored):

- `~/.zshrc.local` - Machine-specific shell config, env vars, secrets
- `~/.gitconfig.local` - Machine-specific git config

Example `~/.zshrc.local`:
```bash
export COMPANY_API_KEY="..."
export AWS_PROFILE="work"
```

## Key Tools & Shortcuts

### Shell Aliases
| Alias | Command |
|---|---|
| `ll` | `eza -la --icons --git` |
| `cat` | `bat` |
| `gs` | `git status` |
| `lg` | `lazygit` |
| `k` | `kubectl` |
| `mvnci` | `mvn clean install` |
| `mvncs` | `mvn clean install -DskipTests` |

### Tmux Shortcuts
| Key | Action |
|---|---|
| `Ctrl+a` | Prefix (instead of Ctrl+b) |
| `Prefix + \|` | Split pane vertically |
| `Prefix + -` | Split pane horizontally |
| `Prefix + h/j/k/l` | Navigate panes (vim-style) |
| `Prefix + r` | Reload tmux config |

### NeoVim Shortcuts
| Key | Action |
|---|---|
| `Space + ff` | Find files (Telescope) |
| `Space + fg` | Live grep (Telescope) |
| `Space + fb` | Find buffers |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `Space + rn` | Rename symbol |
| `Space + ca` | Code action |

## Updating

After making changes to your dotfiles:

```bash
cd ~/dotfiles
git add -A
git commit -m "update: description of change"
git push
```

On another machine, pull and re-stow:

```bash
cd ~/dotfiles
git pull
stow . --restow --target=$HOME
```

## Removing

To cleanly remove all symlinks:

```bash
cd ~/dotfiles
./setup_env.sh --unstow
```
