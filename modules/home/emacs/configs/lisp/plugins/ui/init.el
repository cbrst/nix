;;; init.el --- UI composition -*- lexical-binding: t; -*-
(dolist (module '("search" "tree" "terminal" "vcs" "modeline"))
  (load (expand-file-name (concat "plugins/ui/" module) config-lisp-directory) nil 'nomessage))
(require 'hl-todo)
(global-hl-todo-mode 1)
(require 'rainbow-mode)
(add-hook 'prog-mode-hook #'rainbow-mode)
(require 'highlight-indent-guides)
(setq highlight-indent-guides-method 'character
      highlight-indent-guides-responsive 'top)
(add-hook 'prog-mode-hook #'highlight-indent-guides-mode)
(require 'breadcrumb)
(breadcrumb-mode 1)
