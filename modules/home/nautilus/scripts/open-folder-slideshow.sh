folder=${1:?Usage: open-folder-slideshow FOLDER}

if [[ ! -d "$folder" ]]; then
  exit 1
fi

exec mpv \
  --directory-mode=recursive \
  --fs \
  --image-display-duration=5 \
  --shuffle \
  -- "$folder"
