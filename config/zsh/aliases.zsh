#!/usr/bin/env zsh
# ============================================================================
# aliases.zsh — command aliases
# Sourced from ~/.zshrc BEFORE functions.zsh, because zsh expands aliases at
# the time a function is *parsed* — several functions (coverCommons,
# del_branch_below, streamjesse, omnistatus, …) reference the aliases below in
# their bodies, so the aliases must exist first.
# ============================================================================

# --- git -------------------------------------------------------------------
alias gs="git status --short"
alias branches="git branch -l"
alias br="git branch"
alias reset="git reset"
alias reseth="git reset --hard"
alias gu="git push -u origin"
alias gd="git pull"

# --- kubernetes ------------------------------------------------------------
alias k="kubectl"
alias getpods="kubectl get pods"
alias prettyPodLogs="kubectl logs <pod> -f | jq"
alias deadLogTales="kubectl logs <pod> -p"
alias jesse="kubectl get pods -o wide  | grep -v Running"   # is anything not Running?
alias grpc="grpcui --plaintext localhost:50051"
alias getbbconfig="kubectl describe configmap bb-config-conf | code -"
alias skunkForward="kubectl port-forward service/skunkdb 8432:5432 -n='default'"
alias matrixdbForward="kubectl port-forward service/matrix-db 8431:5432 -n='default'"

# --- gcloud / db -----------------------------------------------------------
alias skunk="gcloud sql connect development-skunk -u skunk --project tcn-cloud-dev"
alias cloudservices="gcloud services list"
alias gemi="GOOGLE_CLOUD_PROEJCT=tcn-cloud-dev gemini"

# --- editors / config / project nav ----------------------------------------
alias vim="nvim"
alias vdev="/usr/local/bin/nvim"
alias config="vim ~/.dotfiles/nvim"
alias zshrc="vim ~/.zshrc"
alias kittyconf="vim ~/.config/kitty/kitty.conf"
alias dbui="nvim -c DBUI"
alias reload="source ~/.zshrc"
alias wfmapi="cd ~/Projects/api && nvim && wezterm cli --skip-config set-tab-title wfm-api"
alias scheduler="cd ~/Projects/scheduler && nvim && wezterm cli --skip-config set-tab-title scheduler"
alias wfmui="cd ~/Projects/wfm-ui && nvim && wezterm cli --skip-config set-tab-title wfm-ui"
alias "operator-dev"="cd ~/Projects/neo && yarn operator start"

# --- build / test ----------------------------------------------------------
alias buildprotos="yarn clean && yarn build-protos"
alias testwfm="yarn test --coverage=false"
alias buildneo="rm -rf node_modules/ && rm -rf /tools/frontend-tools/tcn-frontend-scripts/node_modules/ && yarn install"
alias lintapi='api-linter -I ~/Projects/googleapis ./tcn/omni/**/*.proto'
alias plzWollemiClean="plz run tools/wollemi -- symlink list --prune --broken"
alias cCommonsReport="open /Users/brent.whitehead/Projects/neo/coverage/commons/lcov-report/index.html"
alias cOperatorReport="open /Users/brent.whitehead/Projects/neo/coverage/operator/lcov-report/index.html"

# --- misc ------------------------------------------------------------------
alias cl="clear"
alias devclone="~/code/extra/devclone/devclone"
alias runTop="top -o cpu -O +rsize -s 5 -n 20"
alias versions="bash ~/scripts/fetch-versions.sh"

# --- aliases for deduped functions (see functions.zsh) ----------------------
# lms and lmsctl were identical functions; namestart and startWithApi too.
# Kept both names, defined once.
alias lms="lmsctl"
alias namestart="startWithApi"
