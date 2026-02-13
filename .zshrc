# ============================================
# Path Configuration
# ============================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ============================================
# Oh My Zsh Configuration
# ============================================
export ZSH="$HOME/.oh-my-zsh"

plugins=(
    git
    docker
    kubectl
    aws
    terraform
    z
    history
    sudo
    copypath
    web-search
)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ============================================
# Plugin Configuration
# ============================================

# zsh-autosuggestions
if [[ -f $(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting
if [[ -f $(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# fzf
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ============================================
# Tool Initializations
# ============================================

# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[[ -s "$(brew --prefix nvm 2>/dev/null)/nvm.sh" ]] && source "$(brew --prefix nvm)/nvm.sh"
[[ -s "$(brew --prefix nvm 2>/dev/null)/etc/bash_completion.d/nvm" ]] && source "$(brew --prefix nvm)/etc/bash_completion.d/nvm"

# Java (SDKMAN or manual)
export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)

# Maven
export MAVEN_OPTS="-Xms256m -Xmx512m"

# ============================================
# Aliases - General
# ============================================
alias ll="eza -la --icons --git"
alias ls="eza --icons"
alias lt="eza --tree --level=2 --icons"
alias cat="bat --paging=never"
alias grep="rg"
alias find="fd"
alias cd="z"
alias top="htop"
alias man="tldr"
alias vim="nvim"
alias vi="nvim"

# ============================================
# Aliases - Git
# ============================================
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate"
alias lg="lazygit"

# ============================================
# Aliases - Docker & Kubernetes
# ============================================
alias d="docker"
alias dc="docker compose"
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgn="kubectl get nodes"
alias kctx="kubectl config use-context"

# ============================================
# Aliases - Development
# ============================================
alias mvnci="mvn clean install"
alias mvncs="mvn clean install -DskipTests"
alias mvnt="mvn test"

# ============================================
# Functions
# ============================================

mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

port() {
    lsof -i ":$1"
}

# ============================================
# Local Overrides (machine-specific, git-ignored)
# ============================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
