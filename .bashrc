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
export PATH="$HOME/dotfiles/bin/":$PATH
export EDITOR=vim
export BROWSER=firefox
export TERMINAL=foot
export SHELL=/bin/bash

alias ..='cd ..'
alias tig="tig status"
alias ls="ls --color"
alias ll="ls -l"
trap "" SIGTSTP
alias pac=pacman
export PS1="\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ "
setxkbmap -option caps:escape
alias cb='xclip -selection clipboard'
function set_brightness() {
    # 尝试最多 3 次，且不进行验证以提高速度
    ddcutil setvcp 10 $1 --retry 3 --noverify -d 1
}
