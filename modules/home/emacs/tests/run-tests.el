;;; run-tests.el --- Source and behavioral checks -*- lexical-binding: t; -*-
(require 'ert)
(require 'cl-lib)
(make-directory "/tmp/opencode" t)
(setq user-emacs-directory (file-name-as-directory (make-temp-file "/tmp/opencode/emacs-test-" t)))
(defconst config-test-module-directory
  (expand-file-name "../" (file-name-directory load-file-name)))
(load (expand-file-name "configs/early-init.el" config-test-module-directory) nil t)
(load (expand-file-name "configs/init.el" config-test-module-directory) nil t)

(defun config-test-wait (predicate)
  (let ((deadline (+ (float-time) 20)))
    (while (and (not (funcall predicate)) (< (float-time) deadline))
      (accept-process-output nil 0.05))
    (should (funcall predicate))))

(ert-deftest config-source-syntax ()
  (dolist (file (directory-files-recursively config-test-module-directory "\\.el\\'"))
    (with-temp-buffer
      (insert-file-contents file)
      (emacs-lisp-mode)
      (check-parens))))

(ert-deftest config-leader-commands ()
  (cl-labels ((check (map)
                (map-keymap (lambda (_ binding)
                              (cond ((keymapp binding) (check binding))
                                    ((symbolp binding) (should (commandp binding)))))
                            map)))
    (check config-leader-map))
  (with-temp-buffer
    (evil-normal-state)
    (should (eq (key-binding (kbd "SPC c f")) #'config-format))
    (should (eq (key-binding (kbd "SPC o l r")) #'config-ai-edit))
    (should (eq (key-binding (kbd "C-h")) #'evil-window-left))))

(ert-deftest config-project-precedence ()
  (let ((root (make-temp-file "/tmp/opencode/emacs-roots-" t)))
    (unwind-protect
        (progn
          (make-directory (expand-file-name ".git" root))
          (make-directory (expand-file-name ".jj" root))
          (make-directory (expand-file-name "nested/.git" root) t)
          (should (eq (car (config-repository root)) 'jj))
          (should (eq (car (config-repository (expand-file-name "nested" root))) 'git))
          (should (equal (config-project-root root) (file-name-as-directory root))))
      (delete-directory root t))))

(ert-deftest config-ui-hunk-counts ()
  (should (equal '(3 3 4)
                 (config-vcs-diff-counts
                  "@@ -1 +1 @@\n-a\n+b\n@@ -3,0 +4,3 @@\n@@ -8,4 +11,0 @@\n@@ -20,2 +19,2 @@\n"))))

(ert-deftest config-vcs-live-git-and-jj ()
  (dolist (kind '(git jj))
    (let* ((root (make-temp-file "/tmp/opencode/emacs-vcs-" t))
           (default-directory (file-name-as-directory root))
           (config-vcs-cache (make-hash-table :test #'equal))
           (file (expand-file-name "file" root)) buffer)
      (unwind-protect
          (progn
            (should (zerop (if (eq kind 'jj)
                              (call-process "jj" nil nil nil "git" "init" "--colocate")
                            (call-process "git" nil nil nil "init" "-q"))))
            (with-temp-file file (insert "one\ntwo\n"))
            (when (eq kind 'git)
              (should (zerop (call-process "git" nil nil nil "add" "file")))
              (should (zerop (call-process "git" nil nil nil "-c" "user.name=Test"
                                          "-c" "user.email=test@example.invalid"
                                          "-c" "commit.gpgsign=false" "commit" "-qm" "fixture")))
              (with-temp-file file (insert "ONE\ntwo\n"))
              (call-process "git" nil nil nil "add" "file")
              (with-temp-file file (insert "ONE\nTWO\n")))
            (setq buffer (find-file-noselect file))
            (with-current-buffer buffer
              (config-vcs-refresh)
              (config-test-wait
               (lambda () (not (plist-get (gethash config-vcs-repository config-vcs-cache) :busy))))
              (should (string-match-p (regexp-quote (if (eq kind 'jj) "+2 ~0 -0" "+0 ~1 -0"))
                                      (plist-get (gethash config-vcs-repository config-vcs-cache) :text)))))
        (when (buffer-live-p buffer) (kill-buffer buffer))
        (delete-directory root t)))))

(ert-deftest config-terminal-live ()
  (let ((config-terminal-buffers (make-hash-table :test #'equal)) buffer
        (default-directory "/tmp/opencode/"))
    (unwind-protect
        (save-window-excursion
          (setq buffer (config-terminal t "bash"))
          (should (process-live-p (get-buffer-process buffer)))
          (should (eq (key-binding "x") #'eat-self-input))
          (execute-kbd-macro (kbd "ESC ESC"))
          (should (eq evil-state 'normal))
          (should (eq (key-binding (kbd "SPC o t")) #'config-terminal-toggle))
          (evil-insert-state)
          (should (eq (key-binding "x") #'eat-self-input)))
      (when (buffer-live-p buffer)
        (when-let* ((process (get-buffer-process buffer)))
          (set-process-query-on-exit-flag process nil)
          (delete-process process))
        (kill-buffer buffer)))))

(ert-deftest config-language-modes ()
  (dolist (mode '(python-ts-mode js-ts-mode typescript-ts-mode tsx-ts-mode
                 css-ts-mode json-ts-mode yaml-ts-mode lua-mode nix-mode
                 php-mode markdown-mode sh-mode zsh-mode))
    (with-temp-buffer
      (funcall mode)
      (should (eq major-mode mode))
      (when (eq mode 'markdown-mode)
        (should visual-line-mode)
        (should-not auto-fill-function)))))

(ert-deftest config-language-server-routing ()
  (dolist (entry config-lsp-servers)
    (should (executable-find (car (nth 2 entry))))
    (dolist (mode (nth 1 entry))
      (with-temp-buffer
        (setq major-mode mode)
        (should (funcall (lsp--client-activation-fn (gethash (car entry) lsp-clients)) "test" "test")))))
  (with-temp-buffer
    (zsh-mode)
    (should-not (funcall (lsp--client-activation-fn (gethash 'config-bash lsp-clients)) "test.zsh" "zsh"))))

(ert-deftest config-language-servers-live ()
  (dolist (entry '((nix-mode "test.nix" "{ value = 1; }\n")
                   (lua-mode "test.lua" "local value = 1\n")
                   (python-mode "test.py" "value = 1\n")
                   (zsh-mode "test.zsh" "echo hello\n")
                   (markdown-mode "test.md" "# Title\n")
                   (sh-mode "test.sh" "#!/usr/bin/env bash\necho hello\n")
                   (json-ts-mode "test.json" "{}\n")
                   (yaml-ts-mode "test.yaml" "value: 1\n")
                   (css-ts-mode "test.css" "a { color: red; }\n")
                   (html-mode "test.html" "<p>Hello</p>\n")
                   (typescript-ts-mode "test.ts" "const value: number = 1;\n")
                   (php-mode "test.php" "<?php $value = 1;\n")))
    (let* ((root (make-temp-file "/tmp/opencode/emacs-lsp-" t))
           (default-directory (file-name-as-directory root))
           (file (expand-file-name (nth 1 entry) root)) buffer)
      (unwind-protect
          (progn
            (with-temp-file file (insert (nth 2 entry)))
            (setq buffer (find-file-noselect file))
            (with-current-buffer buffer
              (funcall (car entry))
              (lsp-workspace-folders-add root)
              (lsp)
              (config-test-wait
               (lambda () (and (lsp-workspaces)
                               (cl-every (lambda (workspace)
                                           (eq (lsp--workspace-status workspace) 'initialized))
                                         (lsp-workspaces)))))
              (should lsp-completion-mode)
              (should flymake-mode)))
        (when (buffer-live-p buffer)
          (with-current-buffer buffer
            (dolist (workspace (lsp-workspaces)) (lsp-workspace-shutdown workspace)))
          (kill-buffer buffer))
        (delete-directory root t)))))

(ert-deftest config-tree-current-file ()
  (let* ((root (make-temp-file "/tmp/opencode/emacs-tree-" t))
         (file (expand-file-name "file" root)) buffer)
    (unwind-protect
        (save-window-excursion
          (with-temp-file file (insert "example\n"))
          (setq buffer (find-file-noselect file))
          (switch-to-buffer buffer)
          (config-tree-toggle)
          (should (eq (treemacs-current-visibility) 'visible))
          (config-tree-toggle)
          (should-not (eq (treemacs-current-visibility) 'visible)))
      (when (buffer-live-p buffer) (kill-buffer buffer))
      (delete-directory root t))))

(ert-deftest config-surround-key-sequence ()
  (save-window-excursion
    (with-temp-buffer
      (switch-to-buffer (current-buffer))
      (insert "word")
      (goto-char (point-min))
      (evil-normal-state)
      (execute-kbd-macro "saiw)")
      (should (equal (buffer-string) "(word)")))))

(ert-deftest config-format-chains ()
  (dolist (entry '((css-mode "test.css" "a{color:red}")
                   (html-mode "test.html" "<div><p>hi</p></div>")
                   (lua-mode "test.lua" "local x={a=1,b=2}\n")
                   (markdown-mode "test.md" "# Heading\n\nSome text.\n")
                   (php-mode "test.php" "<?php $x=[1,2];\n")
                   (python-mode "test.py" "x = { 'a':1}\n")
                   (zsh-mode "test.zsh" "#!/usr/bin/env zsh\necho hello\n")))
    (let ((root (make-temp-file "/tmp/opencode/emacs-format-" t)))
      (unwind-protect
          (with-temp-buffer
            (setq default-directory (file-name-as-directory root)
                  buffer-file-name (expand-file-name (nth 1 entry) root))
            (insert (nth 2 entry))
            (funcall (car entry))
            (let (done failure)
              (apheleia-format-buffer
               (config-formatter) nil :callback
               (lambda (&rest result) (setq failure (plist-get result :error) done t)))
              (config-test-wait (lambda () done))
              (should-not failure)
              (should (> (buffer-size) 0))))
        (delete-directory root t)))))

(ert-deftest config-ai-explicit-context ()
  (with-temp-buffer
    (setq buffer-file-name "/tmp/opencode/example.lua")
    (insert "first\nsecond\n")
    (goto-char (point-min))
    (should (string-match-p "Lines: 1-1" (config-ai-context nil t)))
    (should (string-match-p "unsaved" (config-ai-context)))
    (should-not agent-shell-permission-responder-function)))

(ert-deftest config-debug-python-venv ()
  (let ((root (make-temp-file "/tmp/opencode/emacs-python-" t)))
    (unwind-protect
        (let ((default-directory (file-name-as-directory root)))
          (make-directory (expand-file-name ".venv/bin" root) t)
          (with-temp-file (expand-file-name ".venv/bin/python" root) (insert "fixture"))
          (set-file-modes (expand-file-name ".venv/bin/python" root) #o755)
          (should (equal (config-debug-python) (expand-file-name ".venv/bin/python" root))))
      (delete-directory root t))))

(ert-run-tests-batch-and-exit)
