source_image=${1:?Usage: set-noctalia-wallpaper IMAGE}
wallpaper_dir="$HOME/Pictures/Wallpapers"
destination="$wallpaper_dir/wallpaper.jpg"
staging=""
restore_needed=0

notify_failure() {
  notify-send \
    --urgency=critical \
    "Wallpaper update failed" \
    "Could not set $(basename -- "$source_image") as the Noctalia wallpaper."
}

cleanup() {
  status=$?
  trap - EXIT

  if ((restore_needed)); then
    noctalia msg wallpaper-set "$destination" >/dev/null 2>&1 || true
  fi

  if [[ -n "$staging" ]]; then
    rm -f -- "$staging"
  fi

  if ((status != 0)); then
    notify_failure
  fi

  exit "$status"
}
trap cleanup EXIT

if [[ ! -f "$source_image" ]]; then
  exit 1
fi

mkdir -p -- "$wallpaper_dir"

if [[ -e "$destination" && "$source_image" -ef "$destination" ]]; then
  exit 0
fi

staging=$(mktemp "${wallpaper_dir}/.wallpaper-stage.XXXXXX.jpg")
magick "$source_image" "$staging"

# Noctalia caches decoded images by path, so display the staged path first.
noctalia msg wallpaper-set "$staging"
restore_needed=1
sleep 0.75

mv -f -- "$staging" "$destination"
staging=""
noctalia msg wallpaper-set "$destination"
restore_needed=0
