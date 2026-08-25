#!/usr/bin/env zsh
# ============================================================================
# tools.zsh — completions, prompt, and external tool initialization
# Sourced LAST from ~/.zshrc. zsh-syntax-highlighting must be the final thing
# that touches ZLE, so it stays at the bottom of this file.
# ============================================================================

# --- completions -----------------------------------------------------------
# ~/.zfunc holds poetry (and other) completion functions; re-run compinit so
# they're picked up after oh-my-zsh's own compinit.
fpath+=~/.zfunc
autoload -Uz compinit && compinit

# --- powerlevel10k prompt --------------------------------------------------
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- fzf -------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- nvm -------------------------------------------------------------------
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                       # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"    # This loads nvm bash_completion

# --- zoxide ----------------------------------------------------------------
eval "$(zoxide init zsh)"

# --- bun -------------------------------------------------------------------
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# --- Google Cloud SDK ------------------------------------------------------
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# --- misc helpers / rc files -----------------------------------------------
# mamba: disabled — micromamba not installed. To re-enable, run: mamba init
[ -f ~/.python_helpers.sh ] && source ~/.python_helpers.sh
[ -f ~/.tcnrc ] && source ~/.tcnrc

# --- zsh-syntax-highlighting (KEEP LAST) -----------------------------------
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
