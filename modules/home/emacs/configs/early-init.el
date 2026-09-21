;;; early-init.el --- Nix owns packages -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil
      inhibit-startup-screen t
      frame-inhibit-implied-resize t)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
