jj git fetch &&
jj rebase -s "roots(trunk()..stack(@))" \
-o "trunk()" &&
bookmarks=$(jj bookmark list -r "stack(@)" \
  -T '"-b exact:" ++ name ++ "\n"') &&
if [ -n "$bookmarks" ]; then
  jj git push $bookmarks
else
  echo "No bookmarks in the current stack to push."
fi
