;;; options.el --- Editing defaults -*- lexical-binding: t; -*-
(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      use-short-answers t
      scroll-margin 10
      scroll-conservatively 101
      split-height-threshold nil
      split-width-threshold 160
      read-process-output-max (* 1024 1024)
      select-enable-clipboard t
      mouse-yank-at-point t
      enable-local-variables t
      enable-local-eval 'maybe
      create-lockfiles nil
      backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "autosave/" user-emacs-directory) t))
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(make-directory (expand-file-name "autosave/" user-emacs-directory) t)
(setq-default tab-width 2 indent-tabs-mode t fill-column 80
              truncate-lines t display-line-numbers-type 'relative)
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(when (fboundp 'context-menu-mode) (context-menu-mode 1))
(require 'undo-fu)
(require 'undo-fu-session)
(undo-fu-session-global-mode 1)
(require 'dtrt-indent)
(dtrt-indent-global-mode 1)
