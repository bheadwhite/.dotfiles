# ============================================================================
# ~/.zshrc — orchestrator. Real config lives in ~/.config/zsh/*.zsh.
# Load order matters; see the comments on each source line.
# ============================================================================

# --- Powerlevel10k instant prompt (MUST stay at the very top) ---------------
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go ABOVE this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_CONFIG_DIR="$HOME/.config/zsh"

# --- Environment: PATH, exports, history (before oh-my-zsh) -----------------
source "$ZSH_CONFIG_DIR/env.zsh"

# --- Secrets (tokens, API keys) — kept out of the dotfiles repo -------------
# Create ~/.zshrc.secrets on each machine (export lines only); see that file.
[ -f ~/.zshrc.secrets ] && source ~/.zshrc.secrets

# --- oh-my-zsh --------------------------------------------------------------
export ZSH="/Users/brent.whitehead/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions fzf)
source $ZSH/oh-my-zsh.sh

# --- Post-oh-my-zsh config --------------------------------------------------
# keybindings must come after oh-my-zsh so our vi-mode / autosuggest tweaks win.
source "$ZSH_CONFIG_DIR/keybindings.zsh"
# aliases BEFORE functions: zsh expands aliases at function-parse time.
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "$ZSH_CONFIG_DIR/functions.zsh"
# tools last: completions, prompt, and zsh-syntax-highlighting (which must be
# the final ZLE consumer).
source "$ZSH_CONFIG_DIR/tools.zsh"

# Reference-only material (runbooks, old notes) lives in $ZSH_CONFIG_DIR/notes.zsh
# and is intentionally NOT sourced.
