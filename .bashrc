PS0+='\e]133;C\e\\'

command_done() {
    printf '\e]133;D\e\\'
}
PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }command_done

prompt_marker() {
    printf '\e]133;A\e\\'
}
PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }prompt_marker
osc7_cwd() {
    local strlen=${#PWD}
    local encoded=""
    local pos c o
    for (( pos=0; pos<strlen; pos++ )); do
        c=${PWD:$pos:1}
        case "$c" in
            [-/:_.!\'\(\)~[:alnum:]] ) o="${c}" ;;
            * ) printf -v o '%%%02X' "'${c}" ;;
        esac
        encoded+="${o}"
    done
    printf '\e]7;file://%s%s\e\\' "${HOSTNAME}" "${encoded}"
}
PROMPT_COMMAND=${PROMPT_COMMAND:+${PROMPT_COMMAND%;}; }osc7_cwd

# export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897
export PATH="$HOME/projects/dotfiles/bin:$HOME/dotfiles/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
export EDITOR=vi
export BROWSER=firefox
export TERMINAL=ghostty
export SHELL=/bin/bash
export VISUAL=vi

alias ..='cd ..'
alias tig="tig status"
alias ls="ls --color"
alias ll="ls -l"
trap "" SIGTSTP
alias pac=pacman
vnc() {
    open "vnc://$1.local"
}
# export PS1="\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ "
if [[ $- == *i* ]]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
        hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000001F}]}' >/dev/null
    else
        setxkbmap -option caps:escape
    fi
fi
alias cb='xclip -selection clipboard'
function set_brightness() {
    ddcutil setvcp 10 $1 --noverify -d 1
}

cdb__current_activity() {
    command adb shell dumpsys activity top 2>/dev/null | awk '/ACTIVITY / { print $2; exit }'
}

cdb__current_package() {
    local activity
    activity=$(cdb__current_activity)
    [[ -n "$activity" ]] && printf '%s\n' "${activity%%/*}"
}

cdb() {
    local cmd=$1
    shift
    [[ -z "$cmd" ]] && { echo "Usage: cdb <cur|pkg|act|pid|stop|restart|clear> [args...]"; return 1; }

    case "$cmd" in
        cur|pkg)
            cdb__current_package
            ;;
        act|activity)
            cdb__current_activity
            ;;
        pid)
            local pkg=${1:-$(cdb__current_package)}
            [[ -z "$pkg" ]] && return 1
            command adb shell pidof "$pkg"
            ;;
        stop)
            local pkg=${1:-$(cdb__current_package)}
            [[ -z "$pkg" ]] && return 1
            command adb shell am force-stop "$pkg"
            ;;
        restart)
            local pkg=${1:-$(cdb__current_package)}
            [[ -z "$pkg" ]] && return 1
            command adb shell am force-stop "$pkg"
            command adb shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null
            ;;
        clear)
            local pkg=${1:-$(cdb__current_package)}
            [[ -z "$pkg" ]] && return 1
            command adb shell pm clear "$pkg"
            ;;
        *)
            command adb "$cmd" "$@"
            ;;
    esac
}

cmux() {
    local cmd=$1
    shift
    [[ -z "$cmd" ]] && { echo "Usage: cmux <kill|mv|ls> [args...]"; return 1; }

    case "$cmd" in
        ls)
            local raw_format="#S|#W|#{session_created}|#{session_attached}"
            local data

            data=$(command tmux list-sessions -F "$raw_format" | while IFS='|' read -r name windows ctime attached; do
                local ts formatted_time status
                ts=$(echo "$ctime" | tr -dc '0-9')
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    formatted_time=$(date -r "$ts" "+%m-%d %H:%M" 2>/dev/null)
                else
                    formatted_time=$(date -d "@$ts" "+%m-%d %H:%M" 2>/dev/null)
                fi

                status="detached"
                [[ "$attached" == "1" ]] && status="ATTACHED"
                echo "$name|$windows|$formatted_time|$status"
            done)

            echo -e "SESSION|WINDOWS|CREATED|STATUS\n$data" | awk -F'|' '
                NR==FNR {
                    if (length($1) > max_w) {
                        max_w = length($1)
                    }
                    next
                }
                {
                    C_ID = "\033[1;34m"
                    C_WIN = "\033[0;32m"
                    C_TIME = "\033[0;36m"
                    C_ATTACH = "\033[1;33m"
                    C_RESET = "\033[0m"

                    if (NR == 1) {
                        fmt = "%-" (max_w + 2) "s %-10s %-15s %-10s\n"
                        printf fmt, $1, $2, $3, $4
                    } else {
                        st_col = ($4 == "ATTACHED" ? C_ATTACH : "")
                        fmt = C_ID "%-" (max_w + 2) "s" C_RESET " " C_WIN "%-10s" C_RESET " " C_TIME "%-15s" C_RESET " " st_col "%-10s" C_RESET "\n"
                        printf fmt, $1, $2 "W", $3, $4
                    }
                }
            ' RS='\n' <(echo -e "SESSION|WINDOWS|CREATED|STATUS\n$data") -
            ;;
        kill)
            local pattern=$1
            [[ -z "$pattern" ]] && return 1
            tmux list-sessions -F "#{session_name}" | grep -E "^${pattern//\*/.*}$" | xargs -I{} tmux kill-session -t "{}"
            ;;
        mv)
            local real_src
            real_src=$(tmux list-sessions -F "#{session_name}" | grep -E "^${1//\*/.*}$" | head -n 1)
            [[ -n "$real_src" ]] && tmux rename-session -t "$real_src" "$2"
            ;;
        *)
            command tmux "$cmd" "$@"
            ;;
    esac
}

unset -f cmux 2>/dev/null || true
alias date='date +"%Y-%m-%d %H:%M:%S"'
#
# # Cursor color: very dark grey (#1a1a1a)
# # Disable selection highlight by setting it to default (no color)
# # Bind settings must come after any previous bind calls
# bind 'set enable-bracketed-paste on' 2>/dev/null
#
# # Set cursor color to very dark grey (using OSC 12 sequence)
# echo -ne '\e]12;#1a1a1a\a'
#
# # Alternative: use bind to set cursor style if terminal supports it
# # Disable readline region highlighting (selection highlight)
# bind 'set region-highlight-mode none' 2>/dev/null
#
# # Make selected text not have background color (invisible highlight)
# bind 'set active-region-start-color "\e[m"' 2>/dev/null
# bind 'set active-region-end-color "\e[m"' 2>/dev/null
#
# # Set cursor to blinking block or steady block in dark grey
# # [?17;#1a1a1a;c for color (some terminals)
# # [2 q for steady block
# bind 'set vi-ins-mode-string "\1\e[2 q\e]12;#1a1a1a\a\2"' 2>/dev/null
# bind 'set vi-cmd-mode-string "\1\e[2 q\e]12;#1a1a1a\a\2"' 2>/dev/null
#

# Git wrapper function with feat and add safety features
git() {
  # git feat: 从 origin/master 创建特性分支并创建 Draft MR
  if [[ "$1" == "feat" ]]; then
    local feature_name="$2"
    if [ -z "$feature_name" ]; then
      echo "用法: git feat <feature-name>"
      return 1
    fi

    local branch_name="feat-${feature_name}"
    local current_branch
    current_branch=$(command git rev-parse --abbrev-ref HEAD 2>/dev/null)

    echo "🚀 创建特性分支: $branch_name"

    # 获取最新的 origin/master
    echo "📥 获取最新 origin/master..."
    command git fetch origin master || {
      echo "❌ 获取 origin/master 失败"
      return 1
    }

    # 从 origin/master 创建新分支
    echo "🔀 从 origin/master 创建分支 $branch_name..."
    command git checkout -b "$branch_name" origin/master || {
      echo "❌ 创建分支失败"
      return 1
    }

    # push 到远程
    echo "📤 推送到远程..."
    command git push -u origin "$branch_name" || {
      echo "❌ push 失败，尝试回滚到原分支 $current_branch"
      command git checkout "$current_branch"
      command git branch -D "$branch_name" 2>/dev/null
      return 1
    }

    # 创建 Draft MR
    echo "📝 创建 Draft MR..."
    if command -v glab &>/dev/null; then
      glab mr create --draft --title "Draft: $feature_name" --description "WIP: $feature_name" || {
        echo "⚠️ MR 创建失败，但分支已创建并推送"
      }
    elif command -v gh &>/dev/null; then
      # GitHub CLI - 创建 draft PR
      gh pr create --draft --title "Draft: $feature_name" --body "WIP: $feature_name" || {
        echo "⚠️ PR 创建失败，但分支已创建并推送"
      }
    elif [ -n "$GITLAB_TOKEN" ]; then
      # 使用 GitLab API 创建 MR
      local project_id
      project_id=$(command git remote get-url origin | sed -E 's/.*[:/]([^/]+\/[^/]+)\.git$/\1/' | sed 's/\//%2F/g')
      local target_branch="master"

      curl -s -X POST \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --header "Content-Type: application/json" \
        --data "{\"source_branch\":\"$branch_name\",\"target_branch\":\"$target_branch\",\"title\":\"Draft: $feature_name\",\"description\":\"WIP: $feature_name\",\"work_in_progress\":true}" \
        "https://gitlab.com/api/v4/projects/$project_id/merge_requests" > /dev/null 2>&1 && \
        echo "✅ Draft MR 创建成功" || \
        echo "⚠️ MR 创建失败（可能需要检查 GITLAB_TOKEN 或项目权限），但分支已创建并推送"
    else
      echo "⚠️ 未找到 glab/gh CLI，且 GITLAB_TOKEN 未设置，跳过 MR 创建"
      echo "   分支 $branch_name 已创建并推送至远程"
    fi

    echo "✅ 完成！当前分支: $branch_name"
    return 0
  fi

  # git add 安全检查：阻止 git add -A, git add ., git add --all
  if [[ "$1" == "add" ]]; then
    shift

    for arg in "$@"; do
      case "$arg" in
        -A|--all|.)
          echo "❌ blocked: git add $arg (too broad)"
          return 1
          ;;
      esac
    done

    # 如果没有参数，其实等价于 git add .
    if [ $# -eq 0 ]; then
      echo "❌ blocked: git add (no args = add .)"
      return 1
    fi
  fi

  command git "$@"
}
