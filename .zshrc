# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH/$HOME/Desktop/github/limelight/bin

# Path to your oh-my-zsh installation.
export ZSH="/Users/brent.whitehead/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
export ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

    # vim mode config
    # ---------------

# cursor blinking

# Activate vim mode.
bindkey -v

# Remove mode switching delay.
KEYTIMEOUT=5

## Change cursor shape for different vi modes.
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

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

# Use beam shape cursor for each new prompt.
preexec() {
    echo -ne '\e[5 q'
}

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
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

 #Preferred editor for local and remote sessions
 #if [[ -n $SSH_CONNECTION ]]; then
   #export EDITOR='vim'
 #else
   #export EDITOR='mvim'
 #fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias gs="git status --short"
alias cl="clear"
alias reset="git reset"
alias reseth="git reset --hard"
alias br="git branch"
alias skunk="gcloud sql connect development-skunk -u skunk --project tcn-cloud-dev"
alias skunkForward="kubectl port-forward service/skunkdb 8432:5432"

alias buildprotos="yarn clean && yarn build-protos"
alias zshrc="code ~/.zshrc"
alias nvimrc="code ~/.vim/vim.init"
alias getpods="kubectl get pods"
alias prettyPodLogs="kubectl logs <pod> -f | jq"
alias deadLogTales="kubectl logs <pod> -p"
alias reload="source ~/.zshrc"
alias cloudservices="gcloud services list"
alias k="kubectl"
alias mvim="open -a MacVim"
alias nvimconfig="code ~/.vim/vim.init"
alias creport="open /Users/brent.whitehead/Projects/neo/coverage/lcov-report/index.html"
alias buildneo="rm -rf node_modules/ && rm -rf /tools/frontend-tools/tcn-frontend-scripts/node_modules/ && yarn install"
# how to log within matrix api
# log-pod matrix-api -c matrix-api | rg 'CreateFileTemplate' | jq
# jesses check if anything is running
alias jesse="kubectl get pods -o wide | grep -v Running"
streamjesse() {
    while true; do
        clear;
        jesse;
        sleep 2;
    done
}

alias recomp="touch /Users/brent.whitehead/Projects/neo/operator/src/apps/lms/AsyncAction.ts"

alias streamfront="log-pod matrix-api -f -c matrix-api | rg -v 'room303' | rg -v 'ListNewEvent' | rg -v 'GetHistory'"
alias streamback="stream-pod lms-api -c matrix-lms-api "
alias streamsched="stream-pod lms-sched -c matrix-lms-scheduler"
alias streamautocomplete="stream-pod lms-autocomplete -c matrix-lms-autocomplete "
alias streampersist="stream-pod lms-persist -c matrix-lms-persist"

alias streamfrontjq="streamfront | rg 'severity' | jq"
alias streambackjq="streamback | jq"
alias streamschedjq="streamsched | jq"

alias streamlms="osascript \
-e 'tell application \"iTerm2\" to activate' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"n\" using {command down}' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"streamfrontjq\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"d\" using {command down}' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"streambackjq\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"d\" using {command down}' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"streamschedjq\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52'
"
alias streamlmsstg="osascript \
-e 'tell application \"iTerm2\" to activate' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"n\" using {command down}' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"kstaging\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"streamfrontjq\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"d\" using {command down}' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"kstaging\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"streambackjq\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"d\" using {command down}' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"kstaging\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"streamschedjq\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52'
"

alias checkpush="osascript \
-e 'tell application \"iTerm2\" to activate' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"n\" using {command down}' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"cd projects/neo && yarn test lms/components && yarn lint:check\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"d\" using {command down}' \
-e 'delay 1' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to keystroke \"cd projects/neo && yarn format:check\"' \
-e 'tell application \"System Events\" to tell process \"iTerm2\" to key code 52' \
"

g-add () {
    git add "**/$1/**"
}

get-pod () {
    kubectl get pod | grep $1 | awk '{print $1}' | head -n 1
}
log-pod () {
    pod=$(get-pod $1)
    kubectl logs "$pod" "${@:2:$#-2}"
}
stream-pod () {
    pod=$(get-pod $1)
    kubectl logs "$pod" -f "${@:2:$#-2}"
}

cover () {
    yarn test $1 --coverage --collectCoverageFrom="**/*$1*/**/*.{ts,tsx}" --coveragePathIgnorePatterns=".fixture.*" "${@:2:$#-2}"
}
coverP () {
    echo -n "test: "
    read TEST

    echo -n "coverage dir: "
    read DIR
    yarn test $TEST --coverage --collectCoverageFrom="**/$DIR**/*.{ts,tsx}" --coveragePathIgnorePatterns=".fixture.*" "${@:1:$#-1}"
}

# lms-persist = db
# scheduler = worker. processes the stuff.
# lms-api = backend server. queues all the data for scheduler. all api calls end up being intercepted here.
# watcher = sftpImports
# matrix-api = front end service
# examples: //> log-pod lms-sched | rg '<some_element_id>' | jq  OR //>log-pod lms-sched | rg -v 'debug' | jq
#

#set vim to be editor on command line
set -o vi
bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^H" backward-delete-char      # Control-h also deletes the previous char
bindkey "^U" backward-kill-line
# bindkey "¬" forward-word
# bindkey "˙" backward-word



# CHANGE TO THE LOCATION OF NEO FOR SCRIPT TO WORK
export NEO=~/go/src/git.tcncloud.net/m/neo
export GOPATH=/Users/brent.whitehead/go

# k8s helpers
lms() {
    $NEO/plz-out/bin/services/lms/lmsctl "${@:1:$#-1}"
}


forward-persist() {
    kubectl port-forward service/matrix-lms-persist   50090:50051
}
forward-lms() {
    kubectl port-forward service/matrix-lms-api 50052:50051
}

export EDITOR=/usr/bin/vim
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/brent.whitehead/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/brent.whitehead/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/brent.whitehead/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/brent.whitehead/google-cloud-sdk/completion.zsh.inc'; fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
 [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

 kdev() {
    #### For new DEV ENV
    export KUBECONFIG=~/.kube/dev.conf && \
    gcloud container clusters get-credentials dev-1 --zone us-central1-a --project tcn-cloud-dev
 }
 kstaging() {
    #### For new STAGING ENV
    export KUBECONFIG=~/.kube/staging.conf && \
    gcloud container clusters get-credentials staging-1 --zone us-central1-a --project tcn-cloud-dev
 }
 kus-cbf() {
    #### For new US/CBF ENV
    export KUBECONFIG=~/.kube/cbf.conf && \
    gcloud container clusters get-credentials cbf-1 --zone us-central1-c --project tcn-cloud
 }
 kus-chs() {
    #### For new US-East/CHS ENV
    export KUBECONFIG=~/.kube/chs.conf && \
    gcloud container clusters get-credentials chs-1 --zone us-central1-c --project tcn-cloud
 }
 kau() {
    #### For new AU/SYD ENV
    export KUBECONFIG=~/.kube/syd.conf && \
    gcloud container clusters get-credentials syd-1 --zone australia-southeast1-b --project tcn-cloud
 }
 klon() {
    #### For new EU/LON ENV
    export KUBECONFIG=~/.kube/lon.conf && \
    gcloud container clusters get-credentials lon-1 --zone europe-west2-a --project tcn-cloud
 }
 gcloud-logs() {
    open -a "Google Chrome"  "https://console.cloud.google.com/logs/viewer?project=tcn-cloud"
 }

 listEnv(){
     echo kdev DEV
     echo kstaging STAGING
     echo kus-cbf US/CBF
     echo kus-chs US-East/CHS
     echo kau AU/SYD
     echo klon EU/LON
 }

kdb () {
    kubectl exec admin-0 -it env PGPASSWORD="pass.me1234" psql -- -h skunkdb -U skunk -W skunk
}

forward-persist() {
    kubectl port-forward service/matrix-lms-persist   50090:50051
}

export NEO=/Users/brent.whitehead/projects/neo

evans-persist-repl() {
    cd $NEO && \
        evans -r\
              --host localhost\
              --package matrix.lms\
              --service LmsPersist\
              --port 50090\
              repl
}

#need to plz build services/lms/... first
lmsctl() {
    $NEO/plz-out/bin/services/lms/lmsctl "${@:1:$#-1}"
}
