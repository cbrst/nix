;;; init.el --- Modes and Nix-owned parsers -*- lexical-binding: t; -*-
(require 'treesit)
(require 'lua-mode)
(require 'markdown-mode)
(require 'nix-mode)
(require 'php-mode)
(require 'yaml-mode)
(require 'web-mode)
(require 'pug-mode)
(require 'sass-mode)
(require 'sh-script)
(define-derived-mode zsh-mode sh-mode "Zsh"
  "Shell editing with native Zsh language intelligence."
  (sh-set-shell "zsh"))
(add-to-list 'auto-mode-alist '("\\.zsh\\'\\|/\\.zshrc\\'\\|/\\.zprofile\\'" . zsh-mode))
(add-to-list 'interpreter-mode-alist '("zsh" . zsh-mode))
(add-to-list 'auto-mode-alist '("\\.\\(?:phtml\\|erb\\|vue\\)\\'" . web-mode))
(add-to-list 'auto-mode-alist '("tridactylrc\\'" . conf-mode))
;; Emacs major modes provide their own queries; grammars alone do not add modes.
(dolist (entry '((python python-mode python-ts-mode)
                 (javascript js-mode js-ts-mode)
                 (css css-mode css-ts-mode)
                 (json js-json-mode json-ts-mode)
                 (yaml yaml-mode yaml-ts-mode)
                 (c c-mode c-ts-mode) (cpp c++-mode c++-ts-mode)))
  (when (and (fboundp (nth 2 entry)) (treesit-language-available-p (car entry)))
    (add-to-list 'major-mode-remap-alist (cons (nth 1 entry) (nth 2 entry)))))
(when (treesit-language-available-p 'typescript)
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode)))
(when (treesit-language-available-p 'tsx)
  (add-to-list 'auto-mode-alist '("\\.\\(?:tsx\\|jsx\\)\\'" . tsx-ts-mode)))
(setq treesit-font-lock-level 4
      lua-indent-level 2 js-indent-level 2 css-indent-offset 2
      typescript-ts-mode-indent-offset 2
      web-mode-markup-indent-offset 2 web-mode-code-indent-offset 2
      web-mode-css-indent-offset 2)
(load (expand-file-name "languages/markdown" config-lisp-directory) nil 'nomessage)
(require 'hideshow)
(require 'treesit-fold)
(add-hook 'prog-mode-hook
          (lambda ()
            (condition-case nil (hs-minor-mode 1) (error nil))
            (when (and (fboundp 'treesit-fold-mode) (treesit-parser-list))
              (treesit-fold-mode 1))))
(require 'emmet-mode)
(dolist (hook '(html-mode-hook html-ts-mode-hook web-mode-hook css-mode-hook
                css-ts-mode-hook scss-mode-hook sass-mode-hook pug-mode-hook tsx-ts-mode-hook))
  (add-hook hook #'emmet-mode))
