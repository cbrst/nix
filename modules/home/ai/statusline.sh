#!/usr/bin/env bash
# Claude Code status line mirroring the oh-my-posh prompt:
# user, path, git/jj ref, then model and context-window usage.

input=$(cat)

field() {
	jq -r "$1 // empty" <<<"$input"
}

dir=$(field '.workspace.current_dir // .cwd')
model=$(field '.model.display_name')
context=$(field '.context_window.used_percentage')

bold=$'\e[1m'
dim=$'\e[2m'
green=$'\e[32m'
blue=$'\e[34m'
magenta=$'\e[35m'
reset=$'\e[0m'

path=${dir:-$PWD}
case $path in
"$HOME") path=\~ ;;
"$HOME"/*) path=\~/${path#"$HOME"/} ;;
esac
parent=${path%/*}
leaf=${path##*/}
if [ "$parent" = "$path" ]; then
	path="$bold$leaf$reset"
else
	path="$parent/$bold$leaf$reset"
fi

line="$green$bold${USER:-$(id -un)}$reset  $blue$path$reset"

vcs=""
if [ -n "$dir" ] && cd "$dir" 2>/dev/null; then
	# --ignore-working-copy: never snapshot from a status refresh.
	if jj root --ignore-working-copy >/dev/null 2>&1; then
		bookmarks=$(jj log --ignore-working-copy --no-graph \
			-r 'heads(::@ & bookmarks())' -T 'bookmarks.join(",") ++ ","' 2>/dev/null || true)
		bookmarks=${bookmarks%,}
		change=$(jj log --ignore-working-copy --no-graph -r @ \
			-T 'change_id.shortest(6).prefix() ++ "\t" ++ change_id.shortest(6).rest()' 2>/dev/null || true)
		prefix=${change%%$'\t'*}
		rest=${change#*$'\t'}
		vcs="  $bold$bookmarks$reset$magenta@$bold$prefix$reset$dim$rest$reset"
	elif ref=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null ||
		git --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
		vcs="  $ref"
	fi
fi
[ -n "$vcs" ] && line="$line$magenta$vcs$reset"

[ -n "$model" ] && line="$line  $dim$model$reset"
if [ -n "$context" ]; then
	line="$line $dim$(printf '%.0f' "$context")% ctx$reset"
fi

printf '%s\n' "$line"
