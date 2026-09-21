;;; init.el --- Nix-owned DAP debugging -*- lexical-binding: t; -*-

(require 'dape)

(declare-function config-bind "core" (key command))
(declare-function config-project-root "core" (&optional directory))
(defvar config-bashdb-directory)
(defvar config-bash-executable)
(defvar config-cat-executable)
(defvar config-mkfifo-executable)
(defvar config-pkill-executable)

(defun config-debug-file ()
  "Return the absolute current file name, or report a missing file."
  (or buffer-file-name (user-error "Debugging requires a file buffer")))

(defun config-debug-python ()
  "Prefer a project virtual environment over the Nix Python runtime."
  (or (seq-find #'file-executable-p
                (mapcar (lambda (path)
                          (expand-file-name path (config-project-root)))
                        '(".venv/bin/python" "venv/bin/python")))
      (executable-find "python3")
      (user-error "Nix-owned python3 is unavailable")))

;; Replace download-oriented defaults: adapters and runtimes belong to Nix.
(setq dape-configs
      `((python
         modes (python-mode python-ts-mode)
         ensure dape-ensure-command
         command "debugpy-adapter"
         command-cwd config-project-root
         :type "python" :request "launch"
         :program config-debug-file :cwd config-project-root
         :pythonPath config-debug-python)
        (node
         modes (js-mode js-ts-mode js-jsx-mode tsx-ts-mode
                        typescript-mode typescript-ts-mode)
         ensure dape-ensure-command
         command "js-debug" command-args (:autoport) port :autoport
         host "127.0.0.1" command-cwd config-project-root
         :type "pwa-node" :request "launch"
         :program config-debug-file :cwd config-project-root
         :runtimeExecutable "node" :console "integratedTerminal"
         :sourceMaps t
         :skipFiles ["<node_internals>/**" "${workspaceFolder}/node_modules/**"])
        (node-attach
         modes (js-mode js-ts-mode js-jsx-mode tsx-ts-mode
                        typescript-mode typescript-ts-mode)
         ensure dape-ensure-command
         command "js-debug" command-args (:autoport) port :autoport
         host "127.0.0.1" command-cwd config-project-root
         :type "pwa-node" :request "attach"
         :processId ,(lambda () (read-number "Node process ID: "))
         :cwd config-project-root :sourceMaps t)
        (bash
         ;; Zsh buffers are supported only when the script is Bash-compatible.
         modes (sh-mode bash-ts-mode zsh-mode)
         ensure dape-ensure-command
         command "bash-debug-adapter" command-cwd config-project-root
         :type "bashdb" :request "launch"
         :program config-debug-file :cwd config-project-root
         :pathBash config-bash-executable
         :pathBashdb ,(lambda () (file-truename (or (executable-find "bashdb")
                                                   (user-error "bashdb unavailable"))))
         :pathBashdbLib config-bashdb-directory
         :pathCat config-cat-executable :pathMkfifo config-mkfifo-executable
         :pathPkill config-pkill-executable
         :terminalKind "integrated" :showDebugOutput nil :trace nil)
        (lua
         modes (lua-mode lua-ts-mode)
         ensure dape-ensure-command
         command "local-lua-debug-adapter" command-cwd config-project-root
         :type "lua-local" :request "launch" :cwd config-project-root
         :program ,(lambda ()
                     (list :lua (file-truename
                                 (or (executable-find "lua")
                                     (user-error "Nix-owned lua is unavailable")))
                           :file (config-debug-file))))
        (neovim
         modes (lua-mode lua-ts-mode)
         host "127.0.0.1" port 8086
         :type "nlua" :request "attach")))

(defun config-debug-continue ()
  "Continue a stopped session, or select a configuration to start."
  (interactive)
  ;; Dape exposes no public connection predicate; use its non-signaling lookup.
  (if (dape--live-connection 'parent t)
      (call-interactively #'dape-continue)
    (call-interactively #'dape)))

(defun config-debug-repl-toggle ()
  "Show or hide the Dape REPL without killing the session."
  (interactive)
  (if-let* ((window (get-buffer-window "*dape-repl*")))
      (quit-window nil window)
    (call-interactively #'dape-repl)))

(defun config-debug-neovim ()
  "Attach to an external Neovim OSV debug server on port 8086.
In Neovim first run :lua require('osv').launch({port = 8086}).
Emacs cannot start a debug server inside another editor."
  (interactive)
  (dape (copy-tree (alist-get 'neovim dape-configs))))

(keymap-global-set "<f5>" #'config-debug-continue)
(keymap-global-set "<f10>" #'dape-next)
(keymap-global-set "<f11>" #'dape-step-in)
(keymap-global-set "<f12>" #'dape-step-out)
(config-bind "d b" #'dape-breakpoint-toggle)
(config-bind "d B" #'dape-breakpoint-expression)
(config-bind "d c" #'config-debug-continue)
(config-bind "d l" #'dape-restart)
(config-bind "d r" #'config-debug-repl-toggle)
(config-bind "d u" #'dape-info)
(config-bind "d x" #'dape-quit)
(config-bind "d e" #'dape-evaluate-expression)
(config-bind "d L" #'config-debug-neovim)

(provide 'config-plugins-debug)
;;; init.el ends here
