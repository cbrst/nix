;;; markdown.el --- Soft-wrap prose, format deliberately -*- lexical-binding: t; -*-
(setq markdown-fontify-code-blocks-natively t
      markdown-hide-markup t markdown-hide-urls t)
(add-hook 'markdown-mode-hook
          (lambda ()
            (setq-local truncate-lines nil)
            (visual-line-mode 1)
            (auto-fill-mode -1)))
