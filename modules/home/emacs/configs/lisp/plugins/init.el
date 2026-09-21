;;; init.el --- Explicit subsystem load order -*- lexical-binding: t; -*-
(dolist (module '("plugins/ui/init" "plugins/smart/completion"
                  "plugins/smart/format" "plugins/lsp/init"
                  "plugins/debug/init" "plugins/smart/ai"
                  "plugins/integrations/tasks"))
  (load (expand-file-name module config-lisp-directory) nil 'nomessage))
