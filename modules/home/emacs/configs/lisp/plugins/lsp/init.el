;;; init.el --- Nix-only LSP lifecycle and code commands -*- lexical-binding: t; -*-
(setq lsp-client-packages nil
      lsp-enable-suggest-server-download nil
      lsp-auto-guess-root t
      lsp-completion-provider :none
      lsp-diagnostics-provider :flymake
      lsp-enable-symbol-highlighting t
      lsp-headerline-breadcrumb-enable nil
      lsp-enable-on-type-formatting nil
      lsp-inlay-hint-enable nil
      lsp-enable-snippet t)
(require 'lsp-mode)
(require 'lsp-lens)
(require 'consult-lsp)
(require 'consult-flymake)
(require 'flymake)
(load (expand-file-name "config/lsp-servers" config-lisp-directory) nil 'nomessage)
(dolist (entry config-lsp-servers)
  (let ((modes (nth 1 entry)))
    (lsp-register-client
     (make-lsp-client :new-connection (lsp-stdio-connection (nth 2 entry))
                      :activation-fn (lambda (_file _mode) (memq major-mode modes))
                      :server-id (car entry) :priority 10
                      :initialization-options (nth 3 entry)))))
(dolist (entry '((zsh-mode . "zsh") (lua-mode . "lua") (nix-mode . "nix")
                 (markdown-mode . "markdown") (gfm-mode . "markdown")
                 (php-mode . "php") (scss-mode . "scss")
                 (sass-mode . "sass") (pug-mode . "pug")
                 (yaml-mode . "yaml") (web-mode . "html")))
  (add-to-list 'lsp-language-id-configuration entry))
(lsp-register-custom-settings '(("Lua.completion.callSnippet" "Replace")
                                ("Lua.workspace.library" config-lua-libraries)
                                ("Lua.diagnostics.globals" ["vim"])
                                ("zshcs.experimental.diagnostics" t t)
                                ("zshcs.experimental.hover" t t)))
(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection '("emmet-language-server" "--stdio"))
  :major-modes '(html-mode html-ts-mode web-mode css-mode css-ts-mode scss-mode
                less-css-mode sass-mode pug-mode js-mode js-ts-mode js-jsx-mode tsx-ts-mode)
  :server-id 'config-emmet :add-on? t :priority 10
  :initialization-options '(:showAbbreviationSuggestions t :showExpandedAbbreviation "always")))
(defun config-lsp-start ()
  (when (and buffer-file-name (not noninteractive) (not (file-remote-p default-directory))
             (or (cl-some (lambda (entry) (memq major-mode (nth 1 entry))) config-lsp-servers)
                 (memq major-mode '(html-mode html-ts-mode web-mode pug-mode))))
    (lsp-deferred)))
(add-hook 'after-change-major-mode-hook #'config-lsp-start)
(defun config-lsp-keys ()
  (evil-local-set-key 'normal (kbd "g d") #'lsp-find-definition)
  (evil-local-set-key 'normal (kbd "g D") #'lsp-find-declaration)
  (evil-local-set-key 'normal (kbd "g r") #'lsp-find-references)
  (evil-local-set-key 'normal (kbd "g I") #'lsp-find-implementation)
  (evil-local-set-key 'normal (kbd "K") #'lsp-describe-thing-at-point))
(add-hook 'lsp-mode-hook #'config-lsp-keys)
(config-bind "c a" #'lsp-execute-code-action)
(config-bind "c t" #'lsp-find-type-definition)
(config-bind "c r" #'lsp-rename)
(config-bind "c S" #'consult-lsp-file-symbols)
(config-bind "c j" #'consult-lsp-symbols)
(config-bind "c q" #'flymake-show-buffer-diagnostics)
(config-bind "c x" #'flymake-show-project-diagnostics)
(config-bind "c X" #'consult-flymake)
(config-bind "t h" #'lsp-inlay-hints-mode)
