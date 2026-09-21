;;; keymap.el --- Vim editing and shared leaders -*- lexical-binding: t; -*-
(setq evil-want-keybinding nil evil-want-C-u-scroll t evil-shift-width 2
      evil-want-C-i-jump nil evil-undo-system 'undo-fu
      evil-search-module 'evil-search evil-ex-search-case 'smart
      evil-split-window-below t evil-vsplit-window-right t)
(require 'evil)
(evil-mode 1)
(require 'evil-collection)
(evil-collection-init)
(require 'evil-surround)
(global-evil-surround-mode 1)
(require 'evil-commentary)
(evil-commentary-mode 1)
(require 'evil-args)
(define-key evil-inner-text-objects-map "a" #'evil-inner-arg)
(define-key evil-outer-text-objects-map "a" #'evil-outer-arg)
(require 'evil-matchit)
(global-evil-matchit-mode 1)
(evil-define-key '(normal visual motion) 'global (kbd "SPC") config-leader-map)
(evil-define-key 'normal 'global
  (kbd "C-h") #'evil-window-left (kbd "C-j") #'evil-window-down
  (kbd "C-k") #'evil-window-up (kbd "C-l") #'evil-window-right
  (kbd "<escape>") #'evil-ex-nohighlight)
(evil-define-key 'insert 'global (kbd "C-<return>")
  (lambda () (interactive) (end-of-line) (newline-and-indent)))
;; mini.surround's normal-state add/delete/replace spelling.
(evil-define-key '(normal visual) 'global "s" (make-sparse-keymap))
(evil-define-key 'normal 'global
  "sa" #'evil-surround-edit "sd" #'evil-surround-delete "sr" #'evil-surround-change)
(evil-define-key 'visual 'global "sa" #'evil-surround-region)
(config-bind "w" evil-window-map)
(config-bind "q q" #'save-buffers-kill-emacs)
(config-bind "t v" #'whitespace-mode)
(config-bind "t l" (lambda () (interactive)
                       (setq display-line-numbers
                             (if (eq display-line-numbers 'relative) t 'relative))))
(require 'which-key)
(setq which-key-idle-delay 0.3)
(which-key-mode 1)
(which-key-add-key-based-replacements
  "SPC b" "buffer" "SPC c" "code" "SPC d" "debug" "SPC f" "file"
  "SPC g" "git" "SPC h" "help" "SPC o" "open" "SPC o l" "LLM"
  "SPC q" "quit/session" "SPC s" "search" "SPC t" "toggle" "SPC w" "window")
