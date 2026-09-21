;;; modeline.el --- Mode, diagnostics, LSP and cached repository state -*- lexical-binding: t; -*-
(defvar config-modeline-vcs-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line mouse-1] #'config-vcs-terminal) map))
(defun config-modeline-mode ()
  (let ((colors (pcase evil-state
                  ('insert '("I" "#7bd88f" "#344638"))
                  ('visual '("V" "#fce566" "#4d492f"))
                  ('replace '("R" "#fc618d" "#4d2e37"))
                  ('emacs '("E" "#948ae3" "#393748"))
                  (_ '("N" "#5ad4e6" "#2d4649")))))
    (propertize (concat " " (car colors) " ")
                'face (list :foreground (nth 1 colors) :background (nth 2 colors) :weight 'bold))))
(defun config-modeline-lsp ()
  (when (bound-and-true-p lsp-mode)
    (mapconcat (lambda (workspace)
                 (string-remove-prefix
                  "config-" (symbol-name (lsp--client-server-id (lsp--workspace-client workspace)))))
               (lsp-workspaces) ",")))
(setq-default mode-line-format
              '((:eval (config-modeline-mode))
                " %b" mode-line-modified "  " mode-name
                "  " (:eval (config-modeline-lsp)) " "
                (:eval (when (bound-and-true-p flymake-mode) flymake-mode-line-format))
                mode-line-format-right-align
                (:eval (propertize
                        (concat (unless (eq (car config-vcs-repository) 'jj)
                                  (and (boundp 'vc-mode) vc-mode))
                                " " (plist-get (gethash config-vcs-repository config-vcs-cache) :text))
                        'mouse-face 'mode-line-highlight
                        'local-map config-modeline-vcs-map
                        'help-echo "Open repository UI"))
                "  %l:%c  %p "))
