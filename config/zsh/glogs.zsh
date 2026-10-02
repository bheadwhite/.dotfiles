#!/usr/bin/env zsh
# ============================================================================
# glogs.zsh — fzf completion for glogs terms.
#
# Typing `glogs pod=org-<TAB>` pops fzf over the pod names glogs knows about,
# seeded with what you already typed. Same for app=, ns=, container=, severity=,
# and for a bare word, which completes the term keys themselves.
#
# Why a ZLE widget rather than a completion function: fzf's own completion is
# driven by FZF_COMPLETION_TRIGGER (`**` by default), and making plain TAB open
# fzf would mean setting that trigger to empty — a global change affecting every
# command. This intervenes only when the line starts with `glogs`, and otherwise
# calls whatever TAB was already bound to, so nothing else changes.
#
# Candidates come from `glogs --complete`, which unions live kubectl output with
# a cache of what the logs have actually seen. That union is the point: a pod
# under podGC deletion is gone from kubectl seconds after it exits, so the pod
# most worth naming is one only the cache knows. Warm it with `glogs --refresh`.
#
# Must be sourced AFTER the fzf plugin (so the fallback resolves to
# fzf-completion) and BEFORE zsh-syntax-highlighting.
# ============================================================================

# Whatever TAB meant before we took it — resolved once, at load.
_glogs_fallback_widget=${${(z)$(bindkey '^I')}[2]:-expand-or-complete}

_glogs_fzf_complete() {
  local -a words
  words=(${(z)LBUFFER})

  # Not a glogs line: hand TAB straight back.
  if [[ ${words[1]} != glogs ]]; then
    zle "$_glogs_fallback_widget"
    return
  fi

  # The word under the cursor. Trailing whitespace means we are starting a new
  # one, so there is no prefix to match against.
  local cur=""
  [[ $LBUFFER != *[[:space:]] ]] && cur=${words[-1]}

  # Strip a quote the user opened, so `glogs "DRY <TAB>` still matches.
  cur=${cur#[\"\']}

  local key op prefix kind
  if [[ $cur == *[=~]* ]]; then
    key=${cur%%[=~]*}
    op=${cur:${#key}:1}
    prefix=${cur#*[=~]}
    case $key in
      pod)            kind=pod ;;
      app)            kind=app ;;
      ns|namespace)   kind=ns ;;
      container)      kind=container ;;
      severity)       kind=severity ;;
      # An arbitrary jsonPayload field has no candidate list to offer — the
      # values are whatever the service logged. Fall through to normal TAB.
      *)              zle "$_glogs_fallback_widget"; return ;;
    esac
  else
    kind=key
    prefix=$cur
  fi

  local candidates
  candidates=$(command glogs --complete "$kind" 2>/dev/null)
  if [[ -z $candidates ]]; then
    zle "$_glogs_fallback_widget"
    return
  fi

  local sel
  sel=$(print -r -- "$candidates" | fzf \
    --height=40% --reverse --info=inline \
    --prompt="${kind}> " --query="$prefix" \
    --select-1 --exit-0) || { zle redisplay; return }

  [[ -z $sel ]] && { zle redisplay; return }

  # Rebuild the word. For a key completion the candidate already carries its
  # trailing `=`; for a value we keep the key and operator the user typed.
  local insert
  if [[ $kind == key ]]; then
    insert=$sel
  else
    insert="${key}${op}${sel}"
  fi

  # A field like `DRY RUN` contains a space and has to be quoted, or the shell
  # splits the term in half. Park the cursor inside the quotes so the value can
  # be typed straight away.
  local back=0
  if [[ $insert == *[[:space:]]* ]]; then
    insert="\"${insert}\""
    back=1
  fi

  LBUFFER="${LBUFFER%$cur}${insert}"
  (( back )) && CURSOR=$(( CURSOR - back ))
  zle redisplay
}

zle -N _glogs_fzf_complete
bindkey '^I' _glogs_fzf_complete
