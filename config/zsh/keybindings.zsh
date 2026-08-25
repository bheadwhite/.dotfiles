#!/usr/bin/env zsh
# ============================================================================
# keybindings.zsh — vi mode, cursor shape, key bindings, autosuggest tweaks
# Sourced from ~/.zshrc AFTER oh-my-zsh (so our bindings win and the
# zsh-autosuggestions plugin is already loaded).
# ============================================================================

# --- vi mode ---------------------------------------------------------------
set -o vi             # sets the `vi` option and selects the vi keymap
KEYTIMEOUT=5          # Remove mode-switching delay.

# Change cursor shape for different vi modes.
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] ||
        [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

    elif [[ ${KEYMAP} == main ]] ||
        [[ ${KEYMAP} == viins ]] ||
        [[ ${KEYMAP} = '' ]] ||
        [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
    fi
}
zle -N zle-keymap-select

# Beam cursor on startup and for each new prompt.
[[ -z "$P9K_TTY" ]] || echo -ne '\e[5 q'
preexec() {
    echo -ne '\e[5 q'
}

# --- key bindings ----------------------------------------------------------
bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^H" backward-delete-char      # Control-h also deletes the previous char
bindkey "^U" backward-kill-line
# bindkey "¬" forward-word
# bindkey "˙" backward-word

# Accept the autosuggestion from insert mode. Right arrow is nav-only now (see
# ZSH_AUTOSUGGEST_ACCEPT_WIDGETS below), so we need a real accept key. end-of-line
# is an accept widget, so binding these to it both jumps to EOL and accepts.
bindkey -M viins '^E'   end-of-line    # Ctrl+E → accept (and jump to end of line)
bindkey -M viins '^[OF' end-of-line    # End key, application cursor mode
bindkey -M viins '^[[F' end-of-line    # End key, normal cursor mode
# Ctrl+F → accept via the plugin's dedicated widget (works anywhere on the line).
bindkey -M viins '^F'   autosuggest-accept

# Cmd+Opt+Enter → accept, matching how the same physical chord accepts a Copilot
# suggestion in nvim. The chain: BetterTouchTool rewrites Cmd+Opt+Enter to
# Cmd+Opt+F14 inside WezTerm, which sends this sequence (F14 + Ctrl+Alt) to zsh.
bindkey -M viins '\e[26;7~' autosuggest-accept
bindkey -M vicmd '\e[26;7~' autosuggest-accept

# Tab: ONLY ever do real path/command completion — never accept the gray
# autosuggestion. Accept a history suggestion deliberately with Ctrl+E / Ctrl+F
# / End. Shift-Tab walks backward through the completion menu.
bindkey -M viins '^I' expand-or-complete
bindkey -M viins '^[[Z' reverse-menu-complete

# --- zsh-autosuggestions tweaks --------------------------------------------
# Disable async mode (per https://github.com/romkatv/powerlevel10k/issues/1554).
unset ZSH_AUTOSUGGEST_USE_ASYNC

# The plugin default (fg=8) is too dim to read against our background. Bump the
# ghost text to a lighter gray so the suggestion is actually visible.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'

# Stop Right Arrow (forward-char / vi-forward-char) from accepting the gray
# autosuggestion. It's a nav key, and having it accept lets a stale suggestion
# get glued in after a paste (e.g. Cmd+V then a quick →). Right Arrow now just
# moves the cursor; accept a suggestion deliberately with End or Ctrl+E.
# The plugin re-binds widgets every precmd, so reassigning the array here takes
# effect on the next prompt.
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
