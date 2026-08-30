zstyle ':completion:*' matcher-list \
	'm:{a-zA-Z}={A-Za-z}' \
	'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*' \
	'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true

zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# Clean up SSH completions.
zstyle ':completion:*:*:*:users' ignored-patterns '_*' 'broadcasthost' 'daemon' 'greeter' 'messagebus' 'nixbld*' 'nobody' 'nm-*' 'nscd' 'polkituser' 'systemd-*' 'wpa-supplicant'
zstyle ':completion:*:*:*:hosts' ignored-patterns 'broadcasthost' 'localhost' 'github.com' 'kubernetes.docker.internal'

# Format completion headers (e.g., " options")
zstyle ':completion:*:descriptions' format '%F{blue} %d%f'

# Format warning messages when no completion is found
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'

# Auto-describe options that don't have built-in descriptions
zstyle ':completion:*' auto-description 'specify: %d'
