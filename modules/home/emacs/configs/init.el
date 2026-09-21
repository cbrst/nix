;;; init.el --- Ordered, eager editor configuration -*- lexical-binding: t; -*-
(require 'package)
;; Activate Nix-provided autoloads without contacting package archives.
(setq package-archives nil)
(package-initialize)
(defconst config-directory (file-name-directory (or load-file-name buffer-file-name)))
(defconst config-lisp-directory (expand-file-name "lisp/" config-directory))
;; Tests can point at generated settings without activating Home Manager.
(load (or (getenv "EMACS_NIX_SETTINGS")
          (expand-file-name "nix-settings.el" config-directory)) nil 'nomessage)
(dolist (module '("config/globals" "options" "keymap" "autocmds"
                  "languages/init" "plugins/init" "config/theme"))
  (load (expand-file-name module config-lisp-directory) nil 'nomessage))
