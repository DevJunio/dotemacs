;;; git.el ---  desc  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(require 'core-packages)

(use-package magit
  :defer 3
  :ensure t
  :config
  (ju-after-gui
    (core-handle-popup-same-window magit-status-mode)
    (core-handle-popup-same-window magit-log-mode)
    (core-handle-popup-same-window magit-cherry-mode)
    (core-handle-popup-same-window magit-log-select-mode)
    (core-handle-popup-other-window magit-revision-mode)
    (core-handle-popup-other-window-no-select magit-diff-mode))
  (map ju-git-map
       "g" #'magit
       "c" #'magit-clone))

(use-package pcre2el
  :ensure t)

(use-package magit-todos
  :ensure t
  :after magit
  :init (magit-todos-mode 1))

(use-package forge
  :ensure t
  :after magit)

(use-package git-commit
  :config
;; so `fill-paragraph' works correctly for bullet points
(setq git-commit-major-mode 'org-mode)
(general-add-hook 'git-commit-mode-hook
                  #'auto-fill-mode))

(provide 'git)
;; git.el ends here

;;; git.el ends here
