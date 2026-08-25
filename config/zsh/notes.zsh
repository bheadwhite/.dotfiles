#!/usr/bin/env zsh
# ============================================================================
# notes.zsh — REFERENCE ONLY. This file is NOT sourced by ~/.zshrc.
# It preserves the runbooks, how-to notes, oh-my-zsh template hints, and
# commented-out functions that used to live inline in ~/.zshrc, so nothing
# was lost in the reorg. Read it; it does nothing at runtime.
# ============================================================================

# ---------------------------------------------------------------------------
# matrix api logging notes
# ---------------------------------------------------------------------------
# how to log within matrix api
# jesses check if anything is running

# --------------------------------------------------------------------------
# k8s service map
# --------------------------------------------------------------------------
# lms-persist = db
# scheduler = worker. processes the stuff.
# lms-api = backend server. queues all the data for scheduler. all api calls end up being intercepted here.
# watcher = sftpImports
# matrix-api = front end service
# examples: //> log-pod lms-sched | rg '<some_element_id>' | jq  OR //>log-pod lms-sched | rg -v 'debug' | jq
#

# --------------------------------------------------------------------------
# gissue (commented-out helper, kept for reference)
# --------------------------------------------------------------------------
# gissue() {
#   git branch --show-current | awk -F "-" '{print "https://git.tcncloud.net/m/neo/-/issues/"$1}' | xargs open -a "Google Chrome"
# }
  # current_dir=$(pwd)
  # project_dir=$(echo "$current_dir" | grep -oE "Projects/[^/]+" | cut -d'/' -f2)

# --------------------------------------------------------------------------
# deploy-org runbook
# --------------------------------------------------------------------------
# kube get config
# kubectl get configmap bb-config-conf -o yaml

# portforward a namespace and run it on 9090
# ie robby-bowler namespace
# spin up his namespace on your machine and run it on 9090
# kubectl port-forward -n robert-bowler matrix-api-644948f9df-jfgfv 9090:9090
# start up neo and connect to that namespace on 9090
# yarn start --env.namespace_apihost=http://localhost:9090


# serve up a namespace as a backend endpoint using c.sgu

# this will change your name space
# kubectl config use-context brent-whitehead

# deploy org
# step 1: login to big john
# iterm: ssh c.sgu
# step 2: bring up k9s to see seperate stuff update (optional)
# step 3: gcloud auth login on big john
# step 4: make sure your on the correct git branch. then run `plz run k8s/local:org_push` deploys org service to your namespace
# step 5: deploy p3-api `plz run k8s/local:p3-api_push`
# step 6: deploy matrix api `plz run k8s/local:api_push`
# step 7: now that they're deployed to your namespace, switch to your namespace on your local machine `kubectl config set-context --current --namespace 'brent-whitehead'`
# step 8: login locally to gcloud
# gcloud auth login
# gcloud config set project tcn-cloud-dev
# gcloud config set compute/zone us-central1-a
# gcloud config set compute/region us-central1
# gcloud config set container/cluster dev-1
# gcloud auth configure-docker
# gcloud container clusters get-credentials dev-1
# kubectl config set-context --current --namespace=$(whoami | tr '.' '-')
# step 9: setup the port forward: `kubectl port-forward <podname> 9090:9090`
# step 10: yarn start with 9090 as your front end: `yarn start --env.namespace_apihost=http://localhost:9090`

# --------------------------------------------------------------------------
# cp_plugins (legacy, superseded by module_copy; kept for reference)
# --------------------------------------------------------------------------
# Legacy function definitions removed - see ~/.zsh_functions_pod.sh
# cp_plugins() {
#   # Find the plugins directory
#   plugins_dir=$(find ~/code -maxdepth 1 -type d -name "plugins" | head -n 1)
#   current_folder=$(basename "$PWD")
#
#   # Ensure plugins_dir exists
#   if [[ -z "$plugins_dir" ]]; then
#     echo "❌ Error: No 'plugins' directory found in ~/code"
#     return 1
#   fi
#
#   echo "📂 Copying plugins from: $plugins_dir"
#   echo "📌 Target project: $current_folder"
#
#   # Define destination path
#   node_modules_dir="./node_modules/@m/plugins"
#
#   # Ensure the node_modules structure exists
#   mkdir -p "$node_modules_dir/dist/feedback" "$node_modules_dir/src"
#
#   # Copy dist/src
#   echo "🔄 Copying dist and src..."
#   rm -rf "$node_modules_dir/dist" "$node_modules_dir/src"
#   cp -r "$plugins_dir/dist/src" "$node_modules_dir/dist/"
#   cp -r "$plugins_dir/src" "$node_modules_dir/src/"
#   cp -r "$plugins_dir/dist/tcnapi-connect-es" "$node_modules_dir/"
#
#   # Copy specific feedback file
#   cp "$plugins_dir/dist/feedback/ImageEditorStyling.css" "$node_modules_dir/dist/feedback/" 2>/dev/null || true
#   cp "$plugins_dir/dist/dashboards/components/canvas/drag_drop_grid_layout/resize.svg" "$node_modules_dir/dist/dashboards/components/canvas/drag_drop_grid_layout/" 2>/dev/null || true
#
#   # Copy package.json
#   echo "🔄 Copying package.json..."
#   cp "$plugins_dir/package.json" "$node_modules_dir/"
#
#   echo "✅ Plugins copied successfully!"
# }

# --------------------------------------------------------------------------
# oh-my-zsh template hints (defaults left commented in the installer)
# --------------------------------------------------------------------------
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
