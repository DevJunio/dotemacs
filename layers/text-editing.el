(require 'core-packages)
(require 'popup-handler)

(use-package visual-fill-column
  :ghook 'text-mode-hook 'prog-mode-hook
  :init
  (setq-default visual-fill-column-width 150)
  (setq-default visual-fill-column-center-text t))

(use-package selection-highlight-mode
  :elpaca (:host github
           :repo "balloneij/selection-highlight-mode")
  :config (selection-highlight-mode))

(use-package indent-guide
  :config
  (add-hook 'prog-mode 'indent-guide-mode)
  (set-face-background 'indent-guide-face "unspecified"))

(use-package whitespace
  :elpaca nil
  :demand t
  :config
  (map toggle-map "w" #'whitespace-mode)
  (setq whitespace-style
         '(face tabs spaces trailing lines space-before-tab
                newline indentation empty space-after-tab space-mark
                tab-mark newline-mark missing-newline-at-eof)
         ;; use `fill-column' value
         whitespace-line-column 120
         whitespace-display-mappings
         '((tab-mark ?\t [?\xBB ?\t])
           (newline-mark ?\n [?¬ ?\n])
           (trailing-mark ?\n [?¬ ?\n])
           (space-mark 32 [?·] [?.])
           (space-mark ?\xA0 [?\·] [?_])))

  (defun add-lines-tail ()
    "Add lines-tail to `whitespace-style' and refresh `whitespace-mode'."
    (setq-local whitespace-style (cons 'lines-tail whitespace-style))
    (whitespace-mode))

  (add-hook 'prog-mode-hook #'add-lines-tail))

(setq prettify-symbols-unprettify-at-point 'right-edge)

(defvar default-prettify-alist ())
(setq default-prettify-alist
       '(("lambda" . "λ")

         ("<." . "⋖")
         (">." . "⋗")

         ("->"  . "→")
         ("<-"  . "←")
         ("<->" . "↔")
         ("=>"  . "⇒" )
         ("<=>" . "⇔" )

         ("!="  . "≠")
         ("<="  . "⩽")
         (">="  . "⩾")
         ("..." . "…")
         ("++"  . "⧺" )
         ("+++" . "⧻" )
         ("=="  . "⩵" )
         ("===" . "⩶" )

         ("||-" . "⫦" )
         ("|>"  . "⊳" )
         ("<|"  . "⊲" )
         ("<||" . "⧏" )
         ("||>" . "⧐" )

         ("nil" . "∅")
         ("kbd" . "⌨")
         ("use-package" . "📦")

         ("--"    . "―" )
         ("---"   . "―")))

(defun default-prettify-mode()
  "Enable a prettify with custom symbols"
  (interactive)
  (setq prettify-symbols-alist default-prettify-alist)
  (prettify-symbols-mode -1)
  (prettify-symbols-mode +1)
  (setq prettify-symbols-unprettify-at-point 'right-edge))

(add-hook! '(prog-mode-hook
             text-mode-hook) #'default-prettify-mode)

(defvar org-prettify-alist
  '(("[#a]"  . ? )
    ("[#b]"  . ?⬆)
    ("[#c]"  . ?■)
    ("[#d]"  . ?⬇)
    ("[#e]"  . ?❓)
    ("[ ]"   . ? )
    ("[X]"   . ? )
    ("[-]"   . "" )
    ("#+results:"   . ? )
    ("#+begin_src"  . ? )
    ("#+end_src"    . ?∎ )
    (":end:"        . ?―)))

;; Up-case all keys so "begin_src" and "BEGIN_SRC" has the same icon
(setq org-prettify-alist
      (append (mapcan (lambda (x) (list x (cons (upcase (car x)) (cdr x))))
                      org-prettify-alist)
              org-prettify-alist))

(setq org-prettify-alist
      (append default-prettify-alist org-prettify-alist))

(defun org-prettify-mode()
  (interactive)
  (setq prettify-symbols-alist org-prettify-alist)
  (prettify-symbols-mode -1)
  (prettify-symbols-mode +1)
  (setq prettify-symbols-unprettify-at-point 'right-edge))

(add-hook! 'org-mode-hook #'org-prettify-mode)

(use-package dictionary
  :ensure t
  :bind (:map text-mode-map
              ("M-." . dictionary-lookup-definition))
  :init
  (add-to-list 'display-buffer-alist
               '("^\\*dictionary\\*" display-buffer-in-direction
                 (side . right)
                 (window-width . 50)))
  :custom
  (dictionary-server "dict.org"))

(use-package artbollocks-mode
  :ghook '(org-mode-hook text-mode-hook))

(use-package jinx
  :disabled t
  :init
  (noct-after-buffer (global-jinx-mode))
  :config
  (global-key "C-." #'jinx-correct))

(provide 'text-editing)
