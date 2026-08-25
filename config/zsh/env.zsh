#!/usr/bin/env zsh
# ============================================================================
# env.zsh — PATH, environment variables, and history configuration
# Sourced early from ~/.zshrc, before oh-my-zsh loads.
# ============================================================================

# --- PATH ------------------------------------------------------------------
# All PATH modifications in one place.
eval "$(/opt/homebrew/bin/brew shellenv)"

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"

path=(
  $GOBIN
  $HOME/bin
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/code/setup/useful/bin
  $HOME/code/extra/setup/useful/bin
  $BUN_INSTALL/bin
  $PNPM_HOME
  /Applications/WezTerm.app/Contents/MacOS
  $path
)
typeset -U path
export PATH

# --- Editors ---------------------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"
KUBE_EDITOR="nvim"

# --- General environment ---------------------------------------------------
PROMPT_COMMAND='echo -ne "\033]0;$(basename "$(pwd)")\007"'
export GDK_BACKEND=x11
export DELTA_PAGER="less -M"
export DOCKER_CONFIG=$HOME/.docker
export CLOUDSDK_CONFIG=$HOME/.config/gcloud
export KUBECONFIG=~/.kube/dev.conf
export TZ="America/Denver"  # Set this to your local timezone

# --- Project paths ---------------------------------------------------------
export NEO="$HOME/projects/neo"
export PATH_TO_NEO="$HOME/Projects/neo"
export VIM_LOG=/Users/brent.whitehead/.dotfiles/nvim/lua/bdub/lsp/log.txt
export GITLAB_HOST=git.tcncloud.net
# GITLAB_TOKEN is set in ~/.zshrc.secrets (kept out of the repo)
export MAKE_TEMPLATE="$HOME/code/omni/furious-george/Makefile"

# --- Tool config (init happens in tools.zsh) -------------------------------
export NVM_DIR="$HOME/.nvm"
export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# --- History ---------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
HIST_STAMPS="yyyy-mm-dd"
HISTORY_IGNORE="(ls|cd|pwd|exit|cd|gs|cl|zshrc)*"

setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY        # append to history file (Default)
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.
