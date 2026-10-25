names=$(jj bookmark list -r "heads(::@ & bookmarks())" \
  -T 'name ++ "\n"' | sort -u) &&
if [ -z "$names" ]; then
  echo "No bookmark at or behind @ to move."
  exit 1
fi &&
op=$(jj op log -n 1 --no-graph -T 'id.short()') &&
jj git fetch &&
remote=$(printf '%s\n' "$names" |
  sed 's/.*/remote_bookmarks(exact:"&")/' | paste -sd '|') &&
# Remote changes missing from @'s history. Changes rewritten
# locally, e.g. by rebasing onto trunk, are not new work.
new=$(jj log --no-graph -r "::($remote) ~ ::@" \
  -T 'change_id ++ "\n"' |
  while read -r id; do
    [ -n "$(jj log --no-graph -r "change_id($id) & ::@" \
      -T '"x"')" ] || echo "$id"
  done) &&
if [ -n "$new" ]; then
  onto=$(jj log --no-graph -r "heads($remote)" \
    -T 'commit_id ++ "\n"') &&
  if [ "$(printf '%s\n' "$onto" | wc -l)" -ne 1 ]; then
    echo "Remote bookmarks have diverged; rebase manually."
    exit 1
  fi &&
  jj rebase -s "roots(($remote)..@)" -o "$onto"
fi &&
target='heads(::@ & ~empty() & ~description(exact:""))' &&
if [ -n "$(jj log --no-graph \
  -r "::($target) & mutable() & conflicts()" -T '"x"')" ]; then
  echo "Rebasing onto the remote caused conflicts. Resolve them"
  echo "and push again, or run 'jj op restore $op' to undo the pull."
  exit 1
fi &&
jj bookmark move $(printf '%s\n' "$names" | sed 's/^/exact:/') \
  --to "$target" &&
jj git push $(printf '%s\n' "$names" | sed 's/^/-b exact:/')
