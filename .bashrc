# remind me to fill it
export GOOGLE_CLOUD_PROJECT=''
export GEMINI_API_KEY=''
export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897
export PATH='$HOME/dotfiles/bin/':$PATH
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
alias open="yazi"
alias vi=nvim
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
trap "" SIGTSTP
