;;; completion.el --- Completion and snippet fields -*- lexical-binding: t; -*-
(require 'corfu)
(require 'corfu-popupinfo)
(require 'cape)
(require 'yasnippet)
(require 'yasnippet-capf)
(setq corfu-auto t corfu-auto-delay 0.25 corfu-cycle t
      corfu-preview-current nil corfu-quit-no-match 'separator
      tab-always-indent 'complete)
(global-corfu-mode 1)
(corfu-popupinfo-mode 1)
(yas-global-mode 1)
(add-hook 'completion-at-point-functions #'cape-file 90)
(add-hook 'completion-at-point-functions #'yasnippet-capf 80)
(add-hook 'completion-at-point-functions #'cape-dabbrev 95)
(define-key corfu-map (kbd "C-n") #'corfu-next)
(define-key corfu-map (kbd "C-p") #'corfu-previous)
(define-key corfu-map (kbd "C-y") #'corfu-insert)
(define-key yas-keymap (kbd "C-l") #'yas-next-field-or-maybe-expand)
(define-key yas-keymap (kbd "C-h") #'yas-prev-field)
(evil-define-key 'insert 'global (kbd "C-SPC") #'completion-at-point
  (kbd "C-l") #'yas-expand (kbd "C-h") #'backward-delete-char-untabify)
