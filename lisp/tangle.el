;;; juni-tangle.el ---  desc  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
;; * Faster Untangling

(eval-when-compile
  (defconst juni-init-file (concat emacs-dir "juni-config.org")
  "Main init file."))

(defconst juni-unclean-init-file
  (concat emacs-dir "juni-unclean.org")
  "Not yet tracked init file.")

;; http://www.holgerschurig.de/en/emacs-efficiently-untangling-elisp/
(defun tangle-section-canceled ()
  "Return t if the current section header was CANCELED, else nil."
  (save-excursion
    (if (re-search-backward "^\\*+\\s-+\\(.*?\\)?\\s-*$" nil t)
        (string-prefix-p "CANCELED" (match-string 1))
      nil)))

(defun tangle-config-org (orgfile elfile &optional demote-errors)
  "Write all source blocks from ORGFILE into ELFILE.

If DEMOTE-ERRORS is non-nil, wrap each source block with `with-demoted-errors'.

Only source blocks that meet these requirements will be tangled:
- not marked as :tangle no
- have a source-code of =emacs-lisp= or =elisp=
- doesn't have the todo-marker CANCELED"
  (let* (body-list
         (gc-cons-threshold most-positive-fixnum)
         (org-babel-src-block-regexp
          (concat
           ;; (1) indentation                 (2) lang
           "^\\([ \t]*\\)#\\+begin_src[ \t]+\\([^ \f\t\n\r\v]+\\)[ \t]*"
           ;; (3) switches
           "\\([^\":\n]*\"[^\"\n*]*\"[^\":\n]*\\|[^\":\n]*\\)"
           ;; (4) header arguments
           "\\([^\n]*\\)\n"
           ;; (5) body
           "\\([^\000]*?\n\\)??[ \t]*#\\+end_src")))
    (with-temp-buffer
      (insert-file-contents orgfile)
      (goto-char (point-min))
      (while (re-search-forward org-babel-src-block-regexp nil t)
        (let ((lang (match-string 2))
              (args (match-string 4))
              (body (match-string 5))
              (canc (tangle-section-canceled)))
          (when (and (or (string= lang "emacs-lisp")
                         (string= lang "elisp"))
                     (not (string-match-p ":tangle\\s-+no" args))
                     (not canc))
            (if demote-errors
                (push (concat "(let (debug-on-error)\n"
                              "(with-demoted-errors \"Init error: %S\"\n"
                              body
                              "))\n\n")
                      body-list)
              (push (concat body "\n")
                    body-list))))))
    (with-temp-file elfile
      ;; NOTE this could potentially cause problems
      (insert (format ";; Don't edit this file, edit %s instead ... -*- lexical-binding: t -*-\n\n"
                      orgfile))
      (apply #'insert (reverse body-list)))
    (message "Wrote %s ..." elfile)))

(defun juni-tangle-org-init (file &optional load compile retangle demote-errors)
  "Tangle org init FILE if it has not already been tangled.
If LOAD is non-nil, load it as well.  If RETANGLE is non-nil,
tangle FILE even if it is not newer than the current tangled
file.  If COMPILE is non-nil, and the uncompiled file is newer,
compile it.  If DEMOTE-ERRORS is non-nil, wrap each source block
with `with-demoted-errors'.

If both LOAD and COMPILE are specified, load the compiled version
of FILE if it is newer than the tangled version.  Otherwise load
the tangled version (since this is much faster than compiling and
then loading).

Only compile if COMPILE is non-nil and LOAD is nil.  In this case,
load the tangled init FILE first.  Compiling after loading ensures
that all required functionality is available (have to add
everything under ~/.emacs.d/straight/build to `load-path' in an
`eval-when-compile', run `straight-use-package-mode' so :straight
is recognized, etc., etc.; it's easier to just compile afterwards).

When there are no errors loading the tangled file, save it with a
\"-stable.el\" or \"-stable.elc\" suffix (depending on which was
loaded)."
  (let* ((base-file (file-name-sans-extension file))
         (org-init file)
         (init-tangled (if demote-errors
                           (format "%s-demoted-errors.el" base-file)
                         (concat base-file ".el")))
         (init-compiled (concat init-tangled "c"))
         (init-tangled-stable (concat base-file "-stable.el"))
         (init-compiled-stable (concat init-tangled-stable "c")))
    (when (or retangle
              (not (file-exists-p init-tangled))
              (file-newer-than-file-p org-init init-tangled))
      (tangle-config-org org-init init-tangled demote-errors))

    (cond ((and load compile (file-newer-than-file-p init-compiled init-tangled))
           (load-file init-compiled)
           ;; successfully loaded without errors; save stable configuration
           (copy-file init-compiled init-compiled-stable t))
          (load
           (load-file init-tangled)
           (unless demote-errors
             ;; successfully loaded without errors; save stable configuration
             (copy-file init-tangled init-tangled-stable t)))
          ((and compile
                ;; using `not' and this order because of the behavior of
                ;; `file-newer-than-file-p' when a file does not exist
                (not (file-newer-than-file-p init-compiled init-tangled)))
           (load-file init-tangled)
           (byte-compile-file init-tangled)))))

(defun tangle-config (&optional load compile retangle demote-errors)
  "Tangle awaken.org.
LOAD, COMPILE, RETANGLE, and DEMOTE-ERRORS are passed to `juni-tangle-org-init'."
  (interactive)
  (juni-tangle-org-init juni-init-file load compile retangle demote-errors)
  ;; TODO clean and move everything to awaken.org
  (when (file-exists-p juni-unclean-init-file)
    (juni-tangle-org-init juni-unclean-init-file load compile retangle demote-errors)))

(provide 'juni-tangle)
;;; tangle.el ends here
