;;; ai.el --- Explicit OpenCode ACP workflows -*- lexical-binding: t; -*-

(require 'agent-shell)
(require 'agent-shell-opencode)

(declare-function config-bind "core" (key command))
(declare-function config-project-root "core" (&optional directory))

;; No provider files, authentication, environment, or model defaults are changed.
;; OpenCode uses the sibling AI module's configuration and Nix-owned executable.
(setq agent-shell-opencode-acp-command '("opencode" "acp")
      agent-shell-permission-responder-function nil)

(defvar config-ai-shells (make-hash-table :test #'equal)
  "OpenCode shell buffers keyed by project root.")

(defun config-ai-shell (&optional fresh)
  "Return this project's OpenCode shell, creating it if needed.
With FRESH, always start a new ACP session rather than restoring one."
  (let* ((root (file-name-as-directory (expand-file-name (config-project-root))))
         (buffer (gethash root config-ai-shells)))
    (when (or fresh (not (buffer-live-p buffer)))
      (let ((default-directory root)
            (agent-shell-cwd-function (lambda () root))
            (agent-shell-session-strategy 'new))
        (setq buffer (agent-shell-start
                      :config (agent-shell-opencode-make-agent-config))))
      (with-current-buffer buffer
        (setq-local agent-shell-permission-responder-function nil))
      (puthash root buffer config-ai-shells))
    buffer))

(defun config-ai-context (&optional selection line)
  "Capture explicit current-file context before switching buffers.
SELECTION requires an active region; LINE uses the region or current line."
  (unless buffer-file-name
    (user-error "AI context requires a file buffer"))
  (when (and selection (not (use-region-p)))
    (user-error "Select text to add to AI context"))
  (let* ((region (and (or selection line) (use-region-p)))
         (start (cond (region (region-beginning))
                      (line (line-beginning-position))
                      (t (point-min))))
         (end (cond (region (region-end))
                    (line (line-end-position))
                    (t (point-max)))))
    (format "File: %s\nLines: %d-%d\nCurrent buffer content%s:\n```\n%s\n```"
            buffer-file-name (line-number-at-pos start)
            (line-number-at-pos (max start (1- end)))
            (if (buffer-modified-p) " (unsaved)" "")
            (buffer-substring-no-properties start end))))

(defun config-ai-toggle ()
  "Toggle this project's OpenCode chat, adding explicit file context on open."
  (interactive)
  (let* ((context (when buffer-file-name (config-ai-context)))
         (root (file-name-as-directory (expand-file-name (config-project-root))))
         (existing (gethash root config-ai-shells))
         (window (and (buffer-live-p existing) (get-buffer-window existing))))
    (if window
        (quit-window nil window)
      (let ((buffer (config-ai-shell)))
        (pop-to-buffer buffer)
        (when context
          (agent-shell-insert :shell-buffer buffer :text context))))))

(defun config-ai-add-selection ()
  "Add the selected text and its file/line location to the chat draft."
  (interactive)
  (let ((context (config-ai-context t)))
    (agent-shell-insert :shell-buffer (config-ai-shell) :text context)))

(defun config-ai-mode ()
  "Select an ACP mode in this project's OpenCode session."
  (interactive)
  (with-current-buffer (config-ai-shell)
    (call-interactively #'agent-shell-set-session-mode)))

(defun config-ai-model ()
  "Select an ACP model in this project's OpenCode session."
  (interactive)
  (with-current-buffer (config-ai-shell)
    (call-interactively #'agent-shell-set-session-model)))

(defun config-ai-edit ()
  "Request an edit of the active region or current line.
Edits use ACP tool permissions, not automatic buffer replacement."
  (interactive)
  (let* ((context (config-ai-context nil t))
         (instruction (read-string "Rewrite instruction: ")))
    (when (string-empty-p (string-trim instruction))
      (user-error "An edit instruction is required"))
    (agent-shell-insert
     :shell-buffer (config-ai-shell) :submit t
     :text (concat "Edit only the indicated selection or line. "
                   "Preserve unrelated changes.\n\n" context "\n\n" instruction))))

(defun config-ai-review ()
  "Start a fresh review with the same prompt as the Neovim workflow."
  (interactive)
  (let ((context (config-ai-context)))
    (agent-shell-insert
     :shell-buffer (config-ai-shell t) :submit t
     :text (concat
            "Review the current changes for bugs, regressions, and missing tests. Report findings first, ordered by severity, with file and line references."
            "\n\n" context))))

(config-bind "o l l" #'config-ai-toggle)
(config-bind "o l a" #'config-ai-add-selection)
(config-bind "o l m" #'config-ai-mode)
(config-bind "o l M" #'config-ai-model)
(config-bind "o l r" #'config-ai-edit)
(config-bind "o l R" #'config-ai-review)

(provide 'config-plugins-smart-ai)
;;; ai.el ends here
