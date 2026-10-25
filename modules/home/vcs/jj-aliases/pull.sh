jj git fetch &&
jj rebase -s "roots(trunk()..stack(@))" \
-o "trunk()"
