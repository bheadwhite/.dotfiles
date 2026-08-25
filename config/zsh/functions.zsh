#!/usr/bin/env zsh
# ============================================================================
# functions.zsh — shell functions
# Sourced from ~/.zshrc AFTER aliases.zsh (functions below reference some
# aliases in their bodies, and zsh expands aliases at function-parse time).
# Grouped: git · kubernetes · versions · coverage · devclone · dev/misc.
# ============================================================================

# --------------------------------------------------------------------------
# git
# --------------------------------------------------------------------------
g-add () {
    git add "**/$1/**"
}

#delete local merged branches
cleanmerged() {
    git branch --merged | egrep -v "(^\*|master|release)" | xargs git branch -D
}

del_branch_below() {
  dry_run=false
  if [ "$1" = "--dry" ]; then
    dry_run=true
    shift
  fi

  num=$1

  branches | sed 's/^..//' | while read branch; do
    branch_num=$(echo $branch | awk -F'-' '{print $1}')
    if [[ $branch_num =~ ^[0-9]+$ ]]; then
      if [ "$branch_num" -lt "$num" ]; then
        if [ "$dry_run" = true ]; then
          echo "delete branch: $branch"
        else
          git branch -d $branch
        fi
      fi
    fi
  done
}

gomni() {
  # peel off the project name of the cwd
  project_name=$(echo $(pwd) | grep -oE "Projects/[^/]+" | cut -d'/' -f2)

  git_issue=$(git branch --show-current | cut -d'-' -f1)
  issue_url="https://git.tcncloud.net/omni/$project_name/-/issues/$git_issue"

  open -a "Google Chrome Canary" "$issue_url"
}

schedulerissue() {
  git_issue=$(git branch --show-current | cut -d'-' -f1)
  issue_url="https://git.tcncloud.net/wfm/wfm-scheduler/-/issues/$git_issue"

  open -a "Google Chrome Canary" "$issue_url"
}

apiissue(){
  git_issue=$(git branch --show-current | cut -d'-' -f1)
  issue_url="https://git.tcncloud.net/wfm/wfm-api/-/issues/$git_issue"

  open -a "Google Chrome Canary" "$issue_url"
}

commitsahead(){
  sh ~/scripts/commits_ahead.sh
}


# --------------------------------------------------------------------------
# kubernetes / pods
# --------------------------------------------------------------------------
get-pod () {
  pod=$(kubectl get pod | grep $1 | awk '{print $1}' | head -n 1)
  if [ -z "$pod" ]; then
    echo "No pod found"
    return 1
  fi
  echo $pod
}

log-pod () {
    pod=$(get-pod $1)
    kubectl logs "$pod" "${@:2:$#-2}"
}

forward-pod () {
    pod=$(get-pod $1)
    echo $pod
    kubectl port-forward "$pod" "${@:2:$#-2}"
}

exec-pod (){
    pod=$(get-pod $1)
    kubectl exec -it "$pod" -- /bin/zsh
    cd ~
}

stream-pod () {
  pod=$(get-pod $1)
  kubectl logs "$pod" -f "${@:2:$#-2}" 2>/dev/null | while IFS= read -r line; do
    if echo "$line" | jq -e . > /dev/null 2>&1; then
      processed_line=$(echo "$line" | jq -R -r '
        fromjson? |
        .time as $ts |
        .time = (
            $ts |
            sub("\\.[0-9]+\\+[0-9]+:[0-9]+$"; "Z") |
            strptime("%Y-%m-%dT%H:%M:%SZ") |
            mktime
        ) | . ')

      ts=$(echo "$processed_line" | jq -r .time)

      # Calculate DST offset and adjust time manually
      offset=$(jq -n 'now | gmtime | mktime - (now | trunc)')
      adjusted_ts=$((ts - offset))

      # Use compatible date command for converting Unix timestamp to local time
      if [ "$(uname)" = "Darwin" ]; then
        # macOS date command
        local_time=$(TZ=$TZ date -r "$adjusted_ts" +"%Y-%m-%d %H:%M:%S %Z")
      else
        # GNU date command
        local_time=$(TZ=$TZ date -d @"$adjusted_ts" +"%Y-%m-%d %H:%M:%S %Z")
      fi

      echo "$processed_line" | jq --arg local_time "$local_time" '.time = $local_time'
    else
      echo "$line"
    fi
  done
}

matrixdb() {
    if [ -z "$1" ]; then
        kubectl exec -it admin-0 -- psql -h matrix-db -U omni
    else
        kubectl exec -it admin-0 -- psql -h matrix-db -U $1
    fi
}

lmsDb() {
    kubectl exec admin-0 -it psql -- -h matrix-db -U lms
}

kdb () {
    kubectl exec admin-0 -it env PGPASSWORD="pass.me1234" psql -- -h skunkdb -U skunk -W skunk
}

#need to plz build services/lms/... first
lmsctl() {
    $NEO/plz-out/bin/services/lms/lmsctl "${@:1:$#-1}"
}

forward-persist() {
    kubectl port-forward service/matrix-lms-persist   50090:50051
}

forward-lms() {
    kubectl port-forward service/matrix-lms-api 50052:50051
}

forward-wfm-api(){
    x=$(kubectl get pods | grep wfm-api | grep -v franco | grep -v joseph | head -n1 | awk '{print $1;}')

    kubectl port-forward $x 50051:50052 & > /dev/null

}

forward-matrix-db(){
  kubectl port-forward service/matrix-db 5432:5432
}

killport() { lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9 }

# // INFO logs - 0 = off, 1 = info, 2 = debug
log-level-up() {
    pod=$(get-pod $1)
    kubectl exec pod/"$pod" -- /bin/bash -c "kill -10 1"
}

# // Debug logs
log-level-down() {
    pod=$(get-pod $1)
    kubectl exec pod/"$pod" -- /bin/bash -c "kill -12 1"
}

streamjesse() {
    while true; do
        clear;
        jesse;
        sleep 2;
    done
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

mpods(){
  mkube -c "yul" get pods -l group=omnichannel
}

pods(){
  k get pods -l group=omnichannel \
  | grep \
    "omni-\(campaigns\|messages\|api\|assets\|attachments\|barge-in-recorder\|campaign-scheduler\|compliance\|conversations\|job-manager\|job-runner\|persist\|provider-dispatcher\|real-time-gateway\|resources\|tasks\|webhook-gateway\)"
}


# --------------------------------------------------------------------------
# versions / status reporting
# --------------------------------------------------------------------------
printversion(){
  echo "Cluster: $KUBE"
  printf "%-25s %-20s\n" "Service" "Version"
  printf "%-25s %-20s\n" "------------------" "--------------------"

  kubectl get pods -l group=compliance -o json | version_filter_fused
}

omniliveversions(){
  mkube -A get pods -l group=omnichannel -o json | parse_env_json_blocks
}

omnistatus(){
  dev_running=$(k get deploy -l group=omnichannel  | grep dev | grep 1/1)
  down_services=$(k get deploy -l group=omnichannel  | grep -v "omni-\(asm\|asm-cleaner\|bot\|inbound-router\)" | grep 0/0)

  echo "Clones running:"
  echo "--------------------------------"
  echo "$dev_running"
  echo " "
  echo "Deployments Down:"
  echo "--------------------------------"
  echo "$down_services"
}

version_filter_fused() {
  jq -r '
    .items[] |
    {
      pod: .metadata.name,
      images: [.status.containerStatuses[].image | split("/") | last]
    }
    | "\(.pod) -> \(.images | join(" "))"
  ' \
  | sed -E 's/(-> )?proxy:enterprise[^ ]* ?/-> /g' \
  | awk -F' -> ' '{
      split($1, parts, "-")
      base = parts[1]
      for (i = 2; i <= length(parts) - 2; i++) {
        base = base "-" parts[i]
      }
      print base " -> " $2
    }' \
  | awk '{
      last = $NF
      print last "\t" $0
    }' \
  | sort \
  | cut -f2- \
  | awk -F' -> ' '!seen[$1]++' \
  | awk -F'->' '{
    split($2, parts, ":");
    name = parts[1];
    version = parts[2];
    gsub(/^ +| +$/, "", name);
    gsub(/^ +| +$/, "", version);
    printf "%-25s %s\n", name, version
  }' | sort -t'|' -k1,1 -u | awk -F'|' '{
    printf "%-25s %s\n", $1, $2
  }' | sort
}

print_env_block() {
  local env="$1"
  local json="$2"
  local dir="$3"

  local hash
  hash=$(print -r -- "$json" | shasum | cut -d' ' -f1)
  local cache_file="$dir/${env}_${hash}.out"

  if [[ -f "$cache_file" ]]; then
    cat "$cache_file"
  else
    {
      echo "$env"
      print -r -- "$json" | version_filter_fused
      echo ""
    } | tee "$cache_file"
  fi
}

parse_env_json_blocks() {
  local current_env=""
  local buffer=""
  local cache_dir="/tmp/env_version_cache"
  mkdir -p "$cache_dir"

  while IFS= read -r line; do
    if [[ "$line" == "### "* ]]; then
      if [[ -n "$buffer" && -n "$current_env" ]]; then
        print_env_block "$current_env" "$buffer" "$cache_dir"
      fi
      current_env="${line### }"
      buffer=""
    else
      buffer+=$line$'\n'
    fi
  done

  if [[ -n "$buffer" && -n "$current_env" ]]; then
    print_env_block "$current_env" "$buffer" "$cache_dir"
  fi
}


# --------------------------------------------------------------------------
# coverage
# --------------------------------------------------------------------------
coverCommons () {
    yarn commons test $1 --coverage --collectCoverageFrom="**/*$1*/**/*.ts" --coveragePathIgnorePatterns=".fixture.*" "${@:2:$#-2}"
    cCommonsReport
}

coverOperator () {
    yarn operator test $1 --coverage --collectCoverageFrom="**/*$1*/**/*.ts" --coveragePathIgnorePatterns=".fixture.*" "${@:2:$#-2}"
    cOperatorReport
}

coverP () {
    echo -n "test: "
    read TEST

    echo -n "coverage dir: "
    read DIR
    yarn operator test $TEST --coverage --collectCoverageFrom="**/$DIR/**/*.{ts,tsx}" --coveragePathIgnorePatterns=".fixture.*" "${@:1:$#-1}"
}

coverageWatch () {
    yarn run test $1 --coverage --collectCoverageFrom="$2" --watch
}

run_app_coverage(){
  apps_dir=$PATH_TO_NEO/ui/operator/src/apps
  apps_list=($(find $apps_dir -mindepth 1 -maxdepth 1 -type d ! -path ".??*" | sort))

  COLUMNS=20
	local ps3
	local dirs
	ps3="select a directory #: "
  dirs=($(find $apps_dir -mindepth 1 -maxdepth 1 -type d ! -path ".??*" | sort | sed 's|.*/\([^/]*\)$|\1|'))

	select dir in ${dirs[@]}; do
    echo "running coverage in the $dir app."
    dir_to_test=$(echo ${apps_list[$REPLY]} | sed 's|.*/src/\(.*\)|\1|');

    cd $PATH_TO_NEO;

    yarn operator test $dir_to_test --coverage --collectCoverageFrom="**/$dir_to_test/**/*.{ts,tsx}" --watch

    output=$(cat coverage/operator/coverage-summary.json | jq '.total')

    echo "coverage for $dir_to_test is $output"

		break
	done
}

get_app_coverage(){
  apps_dir=$PATH_TO_NEO/ui/operator/src/apps
  apps_list=($(find $apps_dir -mindepth 1 -maxdepth 1 -type d ! -path ".??*" | sort))

  dirs=($(find $apps_dir -mindepth 1 -maxdepth 1 -type d ! -path ".??*" | sort | sed 's|.*/\([^/]*\)$|\1|'))

  local temp_dir=$HOME/temp

  if [ ! -f "$temp_dir/app_coverage.json" ]; then
    touch $temp_dir/app_coverage.json
  fi

  local output_file=$temp_dir/app_coverage.json
  local jq_output="[]"

	for dir in ${apps_list[@]}; do
    echo "running coverage in the $dir app."

    dir_to_test=$(echo $dir | sed 's|.*/src/\(.*\)|\1|');
    dir_name=$(echo $dir | sed 's|.*/\([^/]*\)$|\1|');

    cd $PATH_TO_NEO;

    yarn operator test $dir_to_test --coverage --collectCoverageFrom="**/$dir_to_test/**/*.ts" --silent --coverageReporters="json-summary" --testPathIgnorePatterns=".*.test.tsx"

    local app_coverage=$(cat coverage/operator/coverage-summary.json | jq -r '.total' | jq -r --arg name $dir_name '{ "app": $name, "coverage": . }')

    jq_output=$(printf "%s" $jq_output | jq --arg coverage $app_coverage '. + [$coverage | fromjson]')

	done

  printf "%s" $jq_output > $output_file
}


# --------------------------------------------------------------------------
# devclone / pod config sync
# --------------------------------------------------------------------------
# Resolve the current dev pod once via the exact labeled query (fast).
_devclone_pod () {
    local KUBECTL_CMD
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null) || return 1
    $KUBECTL_CMD get po -l tcn.com/development.owner="$(id -nu | sed 's/\./-/g')" \
        -o custom-columns=name:.metadata.name --no-headers=true 2>/dev/null | head -n1
}

# copy_zshrc + generate_prompt collapsed into a SINGLE `kubectl cp`:
# we already know the pod name locally, so bake the POD_NAME/PROMPT lines into
# a temp copy and push once — no remote grep/sed/echo round trips.
_copy_zshrc_with_prompt () {
    local pod=$1 KUBECTL_CMD src aliases_file short_pod_name tmp
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null) || return 1
    src=~/dev/devclone_resources/.zshrc
    aliases_file=~/dev/devclone_resources/aliases.zsh
    if [[ ! -f "$src" ]]; then
        echo "❌ Error: $src doesn't exist locally — skipping zshrc copy" >&2
        return 1
    fi
    short_pod_name=$(echo "$pod" | sed 's/^dev-brent-whitehead-//;s/-[^-]*-[^-]*$//')
    tmp=$(mktemp)
    {
        cat "$src"
        # Sync portable aliases for a consistent workflow inside the pod.
        if [[ -f "$aliases_file" ]]; then
            echo ""
            echo "# ---- aliases synced from ~/dev/devclone_resources/aliases.zsh ----"
            cat "$aliases_file"
        fi
        echo "POD_NAME=$short_pod_name"
        echo 'PROMPT="($POD_NAME) $PROMPT "'
    } > "$tmp"
    if $KUBECTL_CMD cp "$tmp" "$pod":/home/vscode/.zshrc; then
        echo ".zshrc copied (prompt: '$short_pod_name')."
    else
        echo "❌ Error: failed to copy .zshrc to $pod" >&2
        rm -f "$tmp"
        return 1
    fi
    rm -f "$tmp"
}

exec-clone () {
    # Keep the backgrounded nvim job from printing "[2] 12345 ... done" noise.
    setopt local_options no_monitor no_notify
    local KUBECTL_CMD pod nvim_job
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null)
    if [[ -z "$KUBECTL_CMD" ]]; then
        echo "❌ Error: kubectl command not found in PATH"
        return 1
    fi

    # Resolve the pod ONCE and reuse it for every step below.
    pod=$(_devclone_pod)
    if [[ -z "$pod" ]]; then
        echo "❌ Error: No matching pod found."
        return 1
    fi

    # The nvim check/install is independent of the zshrc copy — run it in the
    # background so it overlaps with the copy instead of blocking it.
    install_neovim_in_pod "$pod" &
    nvim_job=$!

    _copy_zshrc_with_prompt "$pod"

    # Let the nvim check finish before dropping into the shell.
    wait "$nvim_job" 2>/dev/null

    $KUBECTL_CMD exec -it "$pod" -- /bin/zsh
}

exec-clone-copy () {
    # Keep the backgrounded nvim job from printing "[2] 12345 ... done" noise.
    setopt local_options no_monitor no_notify
    local KUBECTL_CMD pod nvim_job
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null)
    if [[ -z "$KUBECTL_CMD" ]]; then
        echo "❌ Error: kubectl command not found in PATH"
        return 1
    fi

    # Resolve the pod ONCE and reuse it for every step below.
    pod=$(_devclone_pod)
    if [[ -z "$pod" ]]; then
        echo "❌ Error: No matching pod found."
        return 1
    fi

    # nvim check/install runs in the background, overlapping the config copies.
    install_neovim_in_pod "$pod" &
    nvim_job=$!

    # This variant also ships the full nvim config (tarball), then the zshrc.
    copy_neovim "$pod"
    _copy_zshrc_with_prompt "$pod"

    # Let the nvim check finish before dropping into the shell.
    wait "$nvim_job" 2>/dev/null

    $KUBECTL_CMD exec -it "$pod" -- /bin/zsh
}

copy_neovim () {
    # Ensure kubectl is available
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null)
    if [[ -z "$KUBECTL_CMD" ]]; then
        echo "❌ Error: kubectl command not found in PATH"
        return 1
    fi

    # Accept the pod as an arg (exec-clone-copy already resolved it) and only
    # fall back to a lookup when called standalone.
    POD="${1:-$($KUBECTL_CMD get po -l tcn.com/development.owner="$(id -nu | sed 's/\./-/g')" -o custom-columns=name:.metadata.name --no-headers=true 2>&1)}"
    # Ensure a pod was found
    if [[ -z "$POD" ]]; then
        echo "❌ Error: No matching pod found."
        echo "Debug: kubectl output: $POD"
        return 1
    fi
    echo "📦 Copying Neovim config to pod: $POD"

    tar --no-xattrs -chf nvim.tar ~/.config/nvim 2>&1 || {
        echo "❌ Failed to create tarball."
        return 1
    }

    # Create the config directory in the pod
    $KUBECTL_CMD exec "$POD" -- mkdir -p /home/vscode/.config 2>&1 || {
        echo "❌ Failed to create config directory in pod."
        return 1
    }

    # Copy the tarball to the pod
    $KUBECTL_CMD cp nvim.tar "$POD":/home/vscode/.config/ 2>&1 || {
        echo "❌ Failed to copy nvim.tar to pod."
        return 1
    }

    # Extract the contents and remove the tarball in a single command
    EXTRACT_ERROR=$($KUBECTL_CMD exec "$POD" -- sh -c '
        tar -xf /home/vscode/.config/nvim.tar --strip-components=3 -C /home/vscode/.config &&
        rm /home/vscode/.config/nvim.tar &&
        find /home/vscode/.config/nvim -name "._*" -delete
    ' 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to extract nvim.tar or clean up files."
        echo "Error output: $EXTRACT_ERROR"
        return 1
    fi

    # Remove the local tarball
    rm -f nvim.tar

    # Debug: Check if nvim config was extracted correctly
    echo "🔍 Verifying Neovim config files..."
    $KUBECTL_CMD exec "$POD" -- ls -la /home/vscode/.config/nvim 2>&1 || {
        echo "❌ Neovim config directory not found after extraction."
        return 1
    }

    echo "✅ Neovim config successfully copied!"

    # Run Lazy.nvim update (only if Neovim is installed)
    # Suppress kubectl stderr to avoid auth errors, but still check if nvim exists
    if $KUBECTL_CMD exec "$POD" -- command -v nvim >/dev/null 2>&1; then
        echo "🔄 Running Lazy.nvim update..."
        # Suppress kubectl stderr but capture nvim output
        LAZY_OUTPUT=$($KUBECTL_CMD exec "$POD" -- sh -c 'nvim --headless "+Lazy update" +q 2>&1' 2>/dev/null)
        LAZY_EXIT=$?
        if [[ $LAZY_EXIT -ne 0 ]]; then
            echo "⚠️  Lazy.nvim update failed (non-fatal)."
            if [[ -n "$LAZY_OUTPUT" ]] && [[ ! "$LAZY_OUTPUT" =~ (Error|Unable|executable|getting|credentials|plugin|couldn|API|timeout|memcache|client-go) ]]; then
                echo "   Output: $LAZY_OUTPUT"
            fi
        else
            echo "✅ Lazy.nvim update completed!"
        fi
    else
        echo "ℹ️  Neovim is not installed in the pod. Skipping Lazy.nvim update."
        echo "   Run 'install_neovim_in_pod' to install Neovim, then run this function again."
    fi
}

install_neovim_in_pod () {
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null)
    if [[ -z "$KUBECTL_CMD" ]]; then
        echo "❌ Error: kubectl command not found in PATH"
        return 1
    fi

    # Accept the pod as an arg (exec-clone already resolved it) and only
    # fall back to a lookup when called standalone.
    POD="${1:-$($KUBECTL_CMD get po -l tcn.com/development.owner="$(id -nu | sed 's/\./-/g')" -o custom-columns=name:.metadata.name --no-headers=true 2>&1)}"
    if [[ -z "$POD" ]]; then
        echo "❌ Error: No matching pod found."
        return 1
    fi

    # Latest version: cache GitHub's answer for a day so the common (up-to-date)
    # path skips the network hop entirely.
    local cache=/tmp/.nvim_latest_version LATEST_VERSION=""
    if [[ -f "$cache" ]] && [[ -z "$(find "$cache" -mtime +1 2>/dev/null)" ]]; then
        LATEST_VERSION=$(cat "$cache")
    fi
    if [[ -z "$LATEST_VERSION" ]]; then
        LATEST_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim-releases/releases/latest | grep '"tag_name":' | cut -d '"' -f 4 | sed 's/v//')
        [[ -n "$LATEST_VERSION" ]] && echo "$LATEST_VERSION" > "$cache"
    fi

    # Single round trip: print the installed version, or nothing if nvim is
    # absent (previously this was two separate `kubectl exec` calls).
    local INSTALLED_VERSION
    INSTALLED_VERSION=$($KUBECTL_CMD exec "$POD" -- sh -c 'command -v nvim >/dev/null 2>&1 && nvim --version | head -n 1 | sed "s/^NVIM v//"' 2>/dev/null)

    if [[ -z "$LATEST_VERSION" ]]; then
        echo "⚠️  Could not determine latest Neovim version from GitHub."
        if [[ -n "$INSTALLED_VERSION" ]]; then
            echo "   Keeping current version (v${INSTALLED_VERSION})."
            return 0
        fi
        echo "   No Neovim installed and cannot fetch latest version. Skipping."
        return 1
    fi

    if [[ -n "$INSTALLED_VERSION" ]]; then
        if [[ "$INSTALLED_VERSION" == "$LATEST_VERSION" ]]; then
            echo "✅ Neovim v${INSTALLED_VERSION} is up to date in pod."
            return 0
        fi
        echo "📦 Upgrading Neovim in pod: $POD (v${INSTALLED_VERSION} -> v${LATEST_VERSION})"
    else
        echo "📦 Installing Neovim v${LATEST_VERSION} in pod: $POD"
    fi

    DEB_URL="https://github.com/neovim/neovim-releases/releases/download/v${LATEST_VERSION}/nvim-linux-x86_64.deb"

    INSTALL_ERROR=$($KUBECTL_CMD exec "$POD" -- sh -c '
        SUDO_CMD=""
        if command -v sudo >/dev/null 2>&1; then
            SUDO_CMD="sudo"
        elif [ "$(id -u)" != "0" ]; then
            echo "Error: Need root privileges or sudo to install packages"
            exit 1
        fi

        $SUDO_CMD dpkg --purge neovim 2>/dev/null || true
        $SUDO_CMD dpkg --purge neovim-runtime 2>/dev/null || true
        $SUDO_CMD rm -f /usr/local/bin/nvim /usr/bin/nvim 2>/dev/null || true

        DEB_URL="'"$DEB_URL"'"
        rm -f /tmp/nvim.deb

        if command -v curl >/dev/null 2>&1; then
            curl -f -L -s -S -o /tmp/nvim.deb "$DEB_URL" || { echo "Download failed"; exit 1; }
        elif command -v wget >/dev/null 2>&1; then
            wget -q -O /tmp/nvim.deb "$DEB_URL" || { echo "Download failed"; exit 1; }
        else
            echo "Error: Neither curl nor wget is available"
            exit 1
        fi

        if [ ! -s /tmp/nvim.deb ]; then
            echo "Error: Downloaded file is empty"
            exit 1
        fi

        $SUDO_CMD dpkg -i /tmp/nvim.deb || { echo "dpkg install failed"; rm -f /tmp/nvim.deb; exit 1; }
        rm -f /tmp/nvim.deb

        nvim --version | head -n 1
    ' 2>&1)

    if [[ $? -eq 0 ]]; then
        echo "✅ Neovim v${LATEST_VERSION} installed!"
        return 0
    else
        echo "❌ Failed to install Neovim."
        echo "Error output: $INSTALL_ERROR"
        return 1
    fi
}

copy_config () {
    copy_neovim
    copy_zshrc
}

copy_zshrc () {
    # Ensure kubectl is available
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null)
    if [[ -z "$KUBECTL_CMD" ]]; then
        echo "❌ Error: kubectl command not found in PATH"
        return 1
    fi

    # Find the target pod
    local pod
    pod=$($KUBECTL_CMD get po -l tcn.com/development.owner=$(id -nu | sed 's/\./-/g') -o custom-columns=name:.metadata.name --no-headers=true)
    if [[ -z "$pod" ]]; then
        echo "Error: No matching pod found" >&2
        return 1
    fi

    # Make sure the local source actually exists before trying to copy
    local src=~/dev/devclone_resources/.zshrc
    if [[ ! -f "$src" ]]; then
        echo "❌ Error: $src doesn't exist locally — nothing to copy" >&2
        return 1
    fi

    # Copy the .zshrc file directly, and only claim success if it worked
    if $KUBECTL_CMD cp "$src" "$pod":/home/vscode/.zshrc; then
        echo ".zshrc copied successfully!"
    else
        echo "❌ Error: failed to copy .zshrc to $pod" >&2
        return 1
    fi
}

generate_prompt () {
    # Ensure kubectl is available
    KUBECTL_CMD=$(command -v kubectl 2>/dev/null)
    if [[ -z "$KUBECTL_CMD" ]]; then
        echo "❌ Error: kubectl command not found in PATH"
        return 1
    fi

    # Find the target pod
    local pod
    pod=$($KUBECTL_CMD get po -l tcn.com/development.owner=$(id -nu | sed 's/\./-/g') -o custom-columns=name:.metadata.name --no-headers=true)
    if [[ -z "$pod" ]]; then
        echo "Error: No matching pod found" >&2
        return 1
    fi

    # Strip out the "dev-brent-whitehead-" prefix and the last two alphanumeric parts with hyphens
    local short_pod_name
    short_pod_name=$(echo "$pod" | sed 's/^dev-brent-whitehead-//;s/-[^-]*-[^-]*$//')

    # Check if the variable is already present in .zshrc (suppress kubectl stderr)
    if $KUBECTL_CMD exec "$pod" -- sh -c "grep -q '^POD_NAME=' /home/vscode/.zshrc" 2>/dev/null; then
        $KUBECTL_CMD exec "$pod" -- sh -c "sed -i 's/^POD_NAME=.*/POD_NAME=$short_pod_name/' /home/vscode/.zshrc" 2>/dev/null
    else
        $KUBECTL_CMD exec "$pod" -- sh -c "echo 'POD_NAME=$short_pod_name' >> /home/vscode/.zshrc" 2>/dev/null
    fi

    # Check if the prompt modification is already present (suppress kubectl stderr)
    if ! $KUBECTL_CMD exec "$pod" -- sh -c "grep -q 'PROMPT=\"(\$POD_NAME) \$PROMPT \"' /home/vscode/.zshrc" 2>/dev/null; then
        $KUBECTL_CMD exec "$pod" -- sh -c "echo 'PROMPT=\"(\$POD_NAME) \$PROMPT \"' >> /home/vscode/.zshrc" 2>/dev/null
    fi

    echo "Prompt name set: '$short_pod_name'."
}

cpclone () {
    if [ "$#" -ne 1 ]; then
        echo "Usage: cpclone <local_file_path>"
        return 1
    fi

    local local_file_path=$1
    local remote_project_root="/home/vscode/build/scheduler"  # Update this with the actual remote project root
    local remote_file_path="$remote_project_root/$local_file_path"

    if [ ! -f "$local_file_path" ]; then
        echo "Error: Local file '$local_file_path' does not exist."
        return 1
    fi

    local pod=$(kubectl get po -l tcn.com/development.owner=$(id -nu | sed 's/\./-/g') -o custom-columns=name:.metadata.name --no-headers=true)
    if [ -z "$pod" ]; then
        echo "Error: No pod found."
        return 1
    fi

    echo "Copying $local_file_path to $pod:$remote_file_path"
    kubectl cp "$local_file_path" "$pod":"$remote_file_path"

    if [ $? -eq 0 ]; then
        echo "File copied successfully."
    else
        echo "Error: Failed to copy file."
    fi
}

module_copy(){
  selected=$({ find ~/code -maxdepth 1 -type d; } | fzf)
  current_folder=$(basename "$PWD")

  rm -rf $selected/node_modules/@m/$current_folder/dist
  cp -r ./dist $selected/node_modules/@m/$current_folder

  rm -rf $selected/node_modules/@m/$current_folder/src
  cp -r ./src $selected/node_modules/@m/$current_folder

  rm $selected/node_modules/@m/$current_folder/package.json
  cp ./package.json $selected/node_modules/@m/$current_folder
}


# --------------------------------------------------------------------------
# dev / misc
# --------------------------------------------------------------------------
startWithApi(){
    yarn start --env.namespace_apihost=http://localhost:9090
}

httpCosmos(){
    yarn cosmos:build && cd cosmos-static && npx http-server -p 3000
}

# launch google chrome with debugging
chromebug(){
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
}

evans-persist-repl() {
    cd $NEO && \
        evans -r\
              --host localhost\
              --package matrix.lms\
              --service LmsPersist\
              --port 50090\
              repl
}

jq-skip () {
    jq -R 'fromjson? | select(type == "object")' "${@:1:$#-1}"
}

# authg — quick gcloud re-auth. `gcloud services list` used to be the trick here:
# any API call forces a token refresh, and the refresh is what triggers Google's
# reauth challenge — unlike `gcloud auth login`, which discards the existing grant
# and redoes the whole OAuth dance in the browser. The refresh is the only part we
# ever wanted, so ask for it directly and skip listing every service in the project.
# `authg -f` is the escape hatch for when the refresh token itself is dead.
authg () {
    local account
    account=$(gcloud config get-value account 2>/dev/null)

    if [[ "$1" == "-f" || "$1" == "--force" ]]; then
        gcloud auth login
        return
    fi

    # No stderr redirect: the reauth prompt (and gcloud's own "run gcloud auth
    # login" advice on hard failure) needs to reach the terminal. stdout is
    # dropped so the access token never lands in scrollback.
    if gcloud auth print-access-token >/dev/null; then
        print -P "%F{green}✔%f gcloud auth live — ${account:-no account set}"
        return 0
    fi
    return 1
}

# Source - https://stackoverflow.com/a/79458466
# Posted by ToVine, modified by community. See post 'Timeline' for change history
# Retrieved 2026-05-15, License - CC BY-SA 4.0

# --- TCN auth token helper -------------------------------------------------
# Run any command with a fresh TCN token exported as $TCN_AUTH_TOKEN.
# `tcn-token` (in ~/.local/bin) reads secrets from the Keychain and reuses a
# cached token until it's near expiry, so this is cheap to call repeatedly.
#   usage:  withtoken npm run dev
#           withtoken pnpm start
withtoken() {
  if [[ $# -eq 0 ]]; then
    echo "usage: withtoken <command> [args...]" >&2
    return 2
  fi
  local _tok
  _tok="$(tcn-token)" || { echo "withtoken: failed to obtain token" >&2; return 1; }
  TCN_AUTH_TOKEN="$_tok" \
    TCN_DEV_REGION="dev" \
    TCN_DEV_ORG="4d19da4b-9190-11ea-8079-6a82c857e628" \
    "$@"
}

