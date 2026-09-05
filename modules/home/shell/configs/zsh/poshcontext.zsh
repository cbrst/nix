# vim: set ft=zsh:

set_poshcontext() {
	local scheme portal_scheme

	case "$(uname -s)" in
	Darwin)
		if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
			scheme="dark"
		else
			scheme="light"
		fi
		;;

	Linux)
		# color-scheme values defined by the portal:
		# 0 = no preference, 1 = prefer dark, 2 = prefer light
		portal_scheme="$(
			busctl --user call \
				org.freedesktop.portal.Desktop \
				/org/freedesktop/portal/desktop \
				org.freedesktop.portal.Settings \
				Read ss \
				org.freedesktop.appearance color-scheme \
				2>/dev/null
		)"

		case "$portal_scheme" in
		*"uint32 1"*) scheme="dark" ;;
		*"uint32 2"*) scheme="light" ;;
		*) scheme="unknown" ;;
		esac
		;;

	*)
		scheme="unknown"
		;;
	esac

	export POSH_COLOR_MODE="$scheme"
}
