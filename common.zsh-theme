# https://github.com/jackharrisonsherlock/common

COMMON_PROMPT_SYMBOL="➜"

# Left Prompt
PROMPT='$(common_host)$(common_current_dir)$(common_bg_jobs)$(elapsed_time)$(common_return_status)'

# Right Prompt
RPROMPT='$(common_git_status)'

# Colors
CUSTOM_COLORS_ELAPSED_TIME=red
CUSTOM_COLORS_CURRENT_TIMESTAMP=red
COMMON_COLORS_HOST_ME=green
COMMON_COLORS_CURRENT_DIR=cyan
COMMON_COLORS_RETURN_STATUS_TRUE=green
COMMON_COLORS_RETURN_STATUS_FALSE=yellow
COMMON_COLORS_GIT_STATUS_DEFAULT=green
COMMON_COLORS_GIT_STATUS_STAGED=red
COMMON_COLORS_GIT_STATUS_UNSTAGED=yellow
COMMON_COLORS_GIT_PROMPT_SHA=green
COMMON_COLORS_BG_JOBS=yellow

# --------------------------------------
# Individual functoins

# Elapsed time
# Ref: https://gist.github.com/knadh/123bca5cfdae8645db750bfb49cb44b0
function preexec() {
  timer=$(($(print -P %D{%s%6.})/1000))
}

elapsed_time() {
  if [ $timer ]; then
    now=$(($(print -P %D{%s%6.})/1000))
    elapsed=$(($now-$timer))

    unset timer
    echo "%F{$CUSTOM_COLORS_ELAPSED_TIME}(${elapsed}ms)%{$reset_color%} "
  fi
}
# Timestamp
current_timestamp() {
  echo "%{$fg_bold[$CUSTOM_COLORS_CURRENT_TIMESTAMP]%}%*%{$reset_color%}"
}

# Host
common_host() {
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[$COMMON_COLORS_HOST_ME]%}$me%{$reset_color%}:"
  fi
}

# Current directory
common_current_dir() {
  echo -n "%{$fg_bold[$COMMON_COLORS_CURRENT_DIR]%}%c%{$reset_color%} "
}

# Prompt symbol
common_return_status() {
  echo -n "%(?.%F{$COMMON_COLORS_RETURN_STATUS_TRUE}.%F{$COMMON_COLORS_RETURN_STATUS_FALSE})$COMMON_PROMPT_SYMBOL%f "
}

# Git status
common_git_status() {
    local message=""
    local message_color="%F{$COMMON_COLORS_GIT_STATUS_DEFAULT}"

    # https://git-scm.com/docs/git-status#_short_format
    local staged=$(git status --porcelain 2>/dev/null | grep -e "^[MADRCU]")
    local unstaged=$(git status --porcelain 2>/dev/null | grep -e "^[MADRCU? ][MADRCU?]")

    if [[ -n ${staged} ]]; then
        message_color="%F{$COMMON_COLORS_GIT_STATUS_STAGED}"
    elif [[ -n ${unstaged} ]]; then
        message_color="%F{$COMMON_COLORS_GIT_STATUS_UNSTAGED}"
    fi

    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n ${branch} ]]; then
        message+="${message_color}${branch}%f"
    fi

    echo -n "${message}"
}

# Git prompt SHA
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{%F{$COMMON_COLORS_GIT_PROMPT_SHA}%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%} "

# Background Jobs
common_bg_jobs() {
  bg_status="%{$fg[$COMMON_COLORS_BG_JOBS]%}%(1j.↓%j .)"
  echo -n $bg_status
}
