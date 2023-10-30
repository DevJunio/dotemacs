;;; ui.el ---  desc  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(require 'core-lib)
(require 'core-packages)

;; ** Font
(general-after-gui
  (when (member "Iosevka Custom" (font-family-list))
    (set-frame-font "Iosevka Custom-14" t t)))

(use-package highlight-escape-sequences
  :after 'modus-themes
  :init
  (general-after-gui
    (hes-mode)))

(use-package maple-minibuffer
  :straight (maple-minibuffer
             :host github
             :repo "honmaple/emacs-maple-minibuffer")
  :config
  (setq maple-minibuffer:position-type 'frame-bottom-center
        maple-minibuffer:border-color
        (or (ignore-errors (ewal-get-color 'foreground) "gray50"))
        maple-minibuffer:height nil
        maple-minibuffer:width 0.7
        maple-minibuffer:cache t))

(setq echo-keystrokes 1)

;; Icons
(use-package all-the-icons)

;;  Whitespace
;; Mode-line

;; Them
(use-package all-the-icons-completion
  :init
  (all-the-icons-completion-mode)
  :config
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup))

(use-package kind-icon
  :ensure t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(add-function :after after-focus-change-function
              #'my-change-background)

(defun my-change-background ()
  (dolist (frame (frame-list))
    (pcase (frame-focus-state frame)
      (`t (set-face-background 'default "#131416" frame))
      (`nil (set-face-background 'default "#1f2125" frame)))))

(use-package modus-themes
  :defer 0
  :preface
  (defun set-theme ()
    "Set theme and config."
    (interactive)
    (load-theme 'modus-vivendi-tinted :no-confirm)
    (font-lock-add-keywords 'emacs-lisp-mode
                            '(("'\\|#'\\|\\." . 'font-lock-constant-face)
                              ("(\\|)" . 'font-lock-punctuation-face)
                              ("[0-9]" . 'font-lock-number-face)))
    (set-face-attribute
     'font-lock-constant-face nil
     :foreground "#f9b37f")

    (custom-set-faces
     ;; custom-set-faces was added by Custom.
     ;; If you edit it by hand, you could mess it up, so be careful.
     ;; Your init file should contain only one such instance.
     ;; If there is more than one, they won't work right.
     '(custom-variable-tag ((t (:inherit bold :foreground "medium sea green"))))
     '(dired-directory ((t (:foreground "SkyBlue1"))))
     '(diredp-file-name ((t (:foreground "light blue"))))
     '(flymake-end-of-line-diagnostics-face ((t (:inherit modus-themes-slant
                                                          :box (:line-width (1 . 1) :color "#61647a")
                                                          :height 0.85))))
     '(font-lock-punctuation-face ((t (:foreground "#8c7ec7"))))
     '(fringe ((t (:background "#101d20"))))
     '(whitespace-trailing ((t (:foreground "#9d1f1f"))))
     '(show-paren-match-expression ((t (:box nil :background "#2c273a"))))
     '(flymake-error-echo-at-eol ((t (:foreground "#ff5f59"))))
     '(modus-themes-lang-warning ((t (:underline "#f9b37f"))) t)
     '(cursor ((t (:background "#4b93ab"))))
     '(flymake-note-echo-at-eol ((t (:foreground "#6ae4b9" :box nil))))
     '(font-lock-warning-face ((t (:inherit modus-themes-bold :foreground "violet"))))
     '(whitespace-line ((t (:foreground "gainsboro" :underline (:color "RoyalBlue4" :style wave :position nil)))))
     '(whitespace-space-after-tab ((t (:inherit whitespace-space)))))

    (with-eval-after-load 'hl-line-mode
      (set-face-attribute
       'hl-line nil
       :background "#2c273a"
       :box '(:line-width (-1 . -1):color "#1d1f24" :style 'flat)))

    (set-face-attribute 'fringe nil
                        :background "#101d20")

    (set-face-background 'default "#1d1f24")

    (set-face-attribute 'font-lock-comment-face nil
                        :slant 'italic)

    (set-face-attribute 'font-lock-keyword-face nil
                        :weight 'bold)

    (with-eval-after-load 'eglot
    (set-face-attribute 'eglot-highlight-symbol-face nil
                        :underline t
                        :bold nil))

    (set-face-attribute 'font-lock-number-face nil
     :foreground "#f9b37f")

    (with-eval-after-load 'hl-line-mode
      (set-face-attribute
       'highlight-numbers-number nil
       :foreground "#f9b37f"))

    (set-face-attribute
     'font-lock-regexp-grouping-backslash nil
     :foreground "#f9b37f" :bold nil)

    (set-face-attribute
     'font-lock-regexp-grouping-construct nil
     :foreground "#86b2d3" :bold t)

    (set-face-attribute
     'font-lock-regexp-face nil
     :foreground "#e0def4" :bold t)

    (set-face-attribute ;; comment for test
     'font-lock-comment-face nil
     :foreground "#9c7ec7")

    (with-eval-after-load 'org-mode
      (set-face-attribute ;; comment for test
       'org-hide nil
       :foreground "#8c7ec7"))

    (set-face-attribute
     'font-lock-string-face nil
     :foreground "#a3bbae")

    (set-face-attribute
     'font-lock-builtin-face nil
     :foreground "#bab4fe")

    (set-face-attribute
     'font-lock-keyword-face nil
     :foreground "#bab4fe")

    (set-face-attribute
     'font-lock-function-name-face nil
     :foreground "#97DED7")

    (set-face-attribute
     'show-paren-match nil
     :background "unspecified" :bold t
     :box '(:line-width (-1 . -1) :color "#f8a4b6" :style 'flat)))

  :config
  (require 'modus-themes)
  (general-after-gui
    (set-theme)))

(general-after-gui
  (gsetq-default mode-line-format
                 '(("%e" mode-line-front-space
                    (:propertize
                     ("" mode-line-mule-info mode-line-client mode-line-modified mode-line-remote)
                     display
                     (min-width
                      (5.0)))
                    mode-line-frame-identification
                    mode-line-buffer-identification
                    "   " mode-line-position
                    (vc-mode vc-mode)
                    "  " mode-line-misc-info flymake-mode-line-format " | "  mode-name))))

(provide 'ui)
;;; ui.el ends here