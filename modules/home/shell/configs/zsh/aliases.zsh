(($+commands[bat])) && () {
	alias cat="bat"
	alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
	alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
}

(($+commands[batman])) && () {
	alias man="batman"
}

(($+commands[doggo])) && () {
	alias dig="doggo"
}

# Match the editors' pickers: honour ignore files even outside Git (non-colocated
# jj repos), show dotfiles, and skip VCS metadata. Aliases built on `rg` inherit
# these filters.
(($+commands[rg])) && () {
	alias rg='rg --smart-case --hidden --no-require-git --glob="!**/.git/*" --glob="!**/.jj/*"'
	alias rgi='rg --no-ignore'
	alias rgf='rg --files'
	alias rgl='rg --files-with-matches'
	alias grep='rg'
}
