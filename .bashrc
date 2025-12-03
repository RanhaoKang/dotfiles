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



# remind me to fill it
export GOOGLE_CLOUD_PROJECT=''
export GEMINI_API_KEY=''
export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897
export PATH="$HOME/dotfiles/bin/":$PATH
export EDITOR=nvim
export BROWSER=firefox
export TERMINAL=foot
export SHELL=/bin/bash
export FILE_MANAGER=yazi
export FILE=yazi

alias ..='cd ..'
alias tig="tig status"
alias ls="ls --color"
alias ll="ls -l"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
trap "" SIGTSTP
alias pac=pacman

function vi() {
    if [ -t 0 ]; then
        # No content in stdin, behave like nvim
        command bob run nightly "$@"
    else
        # Content in stdin, use xargs to pass it to nvim
        xargs -o bos run nightly
    fi
}

. ~/dotfiles/extract.sh

