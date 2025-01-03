;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/synthesis/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.



;; Hide emphasis markers (like *bold*, /italic/) for a cleaner view in Org-mode
(setq org-startup-with-inline-images t)

;; Load inline images in org-mode
(add-hook 'org-mode-hook #'org-display-inline-images)

;; Optional: Remove `doom-docs-mode` if it conflicts with image display
(remove-hook 'org-mode-hook 'doom-docs-mode)

(add-hook 'org-mode-hook (lambda () (whitespace-mode -1)))
(setq whitespace-style '(face tabs spaces trailing lines-tail newline empty indentation space-after-tab space-before-tab))




;; STYLE
(after! org
  ;; Header sizes (from level 1 to level 8), inheriting default colors
  (custom-set-faces!
    '(org-level-1 :inherit outline-1 :height 1.5 :weight bold)
    '(org-level-2 :inherit outline-2 :height 1.4 :weight bold)
    '(org-level-3 :inherit outline-3 :height 1.3 :weight semi-bold)
    '(org-level-4 :inherit outline-4 :height 1.2 :weight semi-bold)
    '(org-level-5 :inherit outline-5 :height 1.1 :weight normal)
    '(org-level-6 :inherit outline-6 :height 1.1 :weight normal)
    '(org-level-7 :inherit outline-7 :height 1.1 :weight normal)
    '(org-level-8 :inherit outline-8 :height 1.1 :weight normal)
  )

  ;; Font sizes for bold, italic, and bold-italic text
  (custom-set-faces!
    '(bold :inherit default :weight bold :height 1.2)
    '(italic :inherit default :slant italic :height 1.2)
    '(bold-italic :inherit default :weight bold :slant italic :height 1.2)
  )

  ;; Increase document title and info sizes, preserving colors
  (custom-set-faces!
    '(org-document-title :inherit default :height 1.6 :weight bold)
    '(org-document-info :inherit default :height 1.3 :weight normal)
  )

  ;; Customize font sizes for other Org elements, keeping the default colors
  (custom-set-faces!
    '(org-table :inherit default :height 1.1)
    '(org-code :inherit default :height 1.1)
    '(org-block :inherit default :height 1.1)
    '(org-block-begin-line :inherit default :height 1.0)
    '(org-block-end-line :inherit default :height 1.0)
    '(org-checkbox :inherit default :height 1.2)
    '(org-list-dt :inherit default :height 1.2)
  )

  ;; Ensure Org mode starts with folded view
  (setq org-startup-folded 'content)
)

  ;; soft wrap
  (setq-default truncate-lines nil)


  (setq org-noter-window-location 'vertical)

 ;; FRECENTF
 (setq frecentf-file (expand-file-name "frecentf" doom-local-dir)
      frecentf-max-items 100) ; Adjust the max items as needed

 (frecentf-mode 1) ; Enable frecentf mode

(after! org-noter
  (setq org-noter-auto-save-last-location t
        org-noter-doc-split-fraction '(0.7 . 0.3)))

(setq warning-suppress-types '((org-element)))



;; Auto-sync org-noter to pdfview
(add-hook 'org-mode-hook
          (lambda ()
            (when (bound-and-true-p org-noter-session) ; Ensure org-noter is active
              (add-hook 'after-change-functions
                        (lambda (_beg _end _len)
                          (when (org-entry-get nil "NOTER_PAGE") ; Check for NOTER_PAGE property
                            (org-noter-sync-current-note)))
                        nil t))))


;; Customize font size for annotations in org-noter
(after! org
  (custom-set-faces!
    '(org-default :inherit default :height 1.3) ;; Adjust general text size
    '(org-noter-notes :inherit default :height 1.4))) ;; Specifically for org-noter notes
;; Existing configuration remains unchanged...

;; Org-noter customization
(after! org-noter
  (setq org-noter-auto-save-last-location t
        org-noter-doc-split-fraction '(0.7 . 0.3)
        org-noter-insert-note-no-questions t) ;; Skip asking for location
)

;; Custom function to insert note without location
(defun my/org-noter-insert-note-without-location ()
  "Insert a note without prompting for location."
  (interactive)
  (org-noter-insert-note 'no-question))

;; Rebind Alt+i to insert note without location
(after! org-noter
  (define-key org-noter-doc-mode-map (kbd "M-i") #'my/org-noter-insert-note-without-location))
