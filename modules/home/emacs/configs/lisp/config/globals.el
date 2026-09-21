;;; globals.el --- Shared editor policy -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'subr-x)
(require 'project)
(defvar config-leader-map (make-sparse-keymap))
(dolist (key '("b" "c" "d" "f" "g" "h" "o" "q" "s" "t"))
  (define-key config-leader-map (kbd key) (make-sparse-keymap)))
(define-key config-leader-map (kbd "o l") (make-sparse-keymap))
(define-key config-leader-map (kbd "h b") (make-sparse-keymap))
(defun config-bind (key command)
  "Bind KEY to COMMAND under Space in normal and visual states."
  (define-key config-leader-map (kbd key) command))

(defun config-repository (&optional directory)
  "Return (TYPE . ROOT) for the nearest repository, preferring jj to Git."
  (let ((dir (file-name-as-directory (expand-file-name (or directory default-directory)))))
    (unless (file-remote-p dir)
      (when-let* ((root (locate-dominating-file
                        dir (lambda (path)
                              (or (file-exists-p (expand-file-name ".jj" path))
                                  (file-exists-p (expand-file-name ".git" path)))))))
        (cons (if (file-exists-p (expand-file-name ".jj" root)) 'jj 'git) root)))))
(defun config-project-root (&optional directory)
  "Find the nearest jj/Git root, falling back to DIRECTORY."
  (or (cdr (config-repository directory)) directory default-directory))
(defun config-project-find (directory)
  (when-let* ((repo (config-repository directory)))
    (cons 'config-project (cdr repo))))
(cl-defmethod project-root ((project (head config-project))) (cdr project))
(cl-defmethod project-files ((project (head config-project)) &optional dirs)
  ;; rg understands ignore files even in non-colocated jj repositories.
  (mapcan (lambda (dir)
            (let ((default-directory dir))
              (with-temp-buffer
                (let ((status (process-file "rg" nil t nil "--files" "--hidden"
                                            "-g" "!.git" "-g" "!.jj" "-0")))
                  (unless (memq status '(0 1)) (error "Project file listing failed"))
                  (mapcar (lambda (file) (expand-file-name file dir))
                          (split-string (buffer-string) "\0" t))))))
          (or dirs (list (project-root project)))))
(add-hook 'project-find-functions #'config-project-find)
