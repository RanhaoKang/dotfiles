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
export EDITOR=vi
export BROWSER=firefox
export TERMINAL=foot
export SHELL=/bin/bash

alias ..='cd ..'
alias tig="tig status"
alias ls="ls --color"
alias ll="ls -l"
trap "" SIGTSTP
alias pac=pacman
# export PS1="\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ "
setxkbmap -option caps:escape
alias cb='xclip -selection clipboard'
function set_brightness() {
    ddcutil setvcp 10 $1 --noverify -d 1
}

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
# # [?17;#1a1a1a;c for color (some terminals)
# # [2 q for steady block
# bind 'set vi-ins-mode-string "\1\e[2 q\e]12;#1a1a1a\a\2"' 2>/dev/null
# bind 'set vi-cmd-mode-string "\1\e[2 q\e]12;#1a1a1a\a\2"' 2>/dev/null
#
