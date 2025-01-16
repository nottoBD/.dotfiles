;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Base Configuration
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Theme and Visual Settings
(setq doom-theme 'doom-one)
(setq display-line-numbers-type t)
(setq-default truncate-lines nil)  ; soft wrap

;; Font Configuration
(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

;; Directory Structure
(setq org-directory "~/synthesis/org/")
(setq default-directory "~/synthesis/go/")

;; Frecentf Configuration
(setq frecentf-file (expand-file-name "frecentf" doom-local-dir)
      frecentf-max-items 100)
(frecentf-mode 1)

;; Org Mode Configuration
(after! org
  ;; Header Sizes
  (custom-set-faces!
    '(org-level-1 :inherit outline-1 :height 1.5 :weight bold)
    '(org-level-2 :inherit outline-2 :height 1.4 :weight bold)
    '(org-level-3 :inherit outline-3 :height 1.3 :weight semi-bold)
    '(org-level-4 :inherit outline-4 :height 1.2 :weight semi-bold)
    '(org-level-5 :inherit outline-5 :height 1.1 :weight normal)
    '(org-level-6 :inherit outline-6 :height 1.1 :weight normal)
    '(org-level-7 :inherit outline-7 :height 1.1 :weight normal)
    '(org-level-8 :inherit outline-8 :height 1.1 :weight normal))

  ;; Text Styling
  (custom-set-faces!
    '(bold :inherit default :weight bold :height 1.2)
    '(italic :inherit default :slant italic :height 1.2)
    '(bold-italic :inherit default :weight bold :slant italic :height 1.2)
    '(org-document-title :inherit default :height 1.6 :weight bold)
    '(org-document-info :inherit default :height 1.3 :weight normal)
    '(org-default :inherit default :height 1.3)
    '(org-noter-notes :inherit default :height 1.4))

  ;; Org Settings
  (setq org-startup-folded 'content
        org-startup-with-inline-images t))

;; Org Hooks
(add-hook 'org-mode-hook 'org-display-inline-images)
(add-hook 'org-mode-hook (lambda () (whitespace-mode -1)))
(remove-hook 'org-mode-hook 'doom-docs-mode)

;; Whitespace Configuration
(setq whitespace-style '(face tabs spaces trailing lines-tail newline empty 
                        indentation space-after-tab space-before-tab))

;; Go Development Configuration
(use-package! go-mode
  :hook ((go-mode . lsp-deferred)
         (go-mode . company-mode))
  :config
  (require 'lsp-go)
  (add-hook 'before-save-hook #'lsp-format-buffer nil t)
  (add-hook 'before-save-hook #'lsp-organize-imports nil t))

;; Company Mode Configuration
(use-package! company
  :config
  (setq company-idle-delay 0
        company-minimum-prefix-length 1))

;; LSP Configuration for Go
(after! lsp-mode
  (setq lsp-go-use-gofumpt t)
  (setq lsp-go-analyses
        '((fieldalignment . t)
          (nilness . t)
          (shadow . t)
          (unusedparams . t))))

;; Treemacs Configuration
(after! treemacs
  (setq treemacs-position 'left
        treemacs-width 35)
  ;; Create and setup Go workspace
  (treemacs-create-workspace "Go Projects")
  (treemacs-add-and-display-current-project-exclusively))

;; Custom Go Workspace Function
(defun open-go-workspace ()
  (interactive)
  (treemacs-select-window)
  (cd "~/synthesis/go/")
  (treemacs-add-and-display-current-project-exclusively))

;; Projectile Configuration
(after! projectile
  (setq projectile-project-search-path '("~/synthesis/go/"))
  (setq projectile-auto-discover t))

;; Key Bindings
(map! :leader
      ;; Go workspace bindings
      (:prefix ("o" . "open")
       :desc "Open Go workspace" "g" #'open-go-workspace)
      (:prefix ("p" . "project")
       :desc "Go workspace root" "g" (cmd! (cd "~/synthesis/go/"))))

;; Go Mode Key Bindings
(map! :map go-mode-map
      :leader
      (:prefix ("m" . "major mode")
       (:prefix ("t" . "test")
        "t" #'go-test-current-test
        "f" #'go-test-current-file
        "p" #'go-test-current-project)
       (:prefix ("g" . "go")
        "i" #'go-goto-imports
        "f" #'go-fill-struct
        "a" #'go-tag-add
        "r" #'go-tag-remove)))

;; Go Mode Theme Customization
(custom-set-faces!
  '(go-mode-keyword :foreground "#51afef")
  '(go-mode-function-name :foreground "#98be65")
  '(go-mode-string :foreground "#98be65")
  '(go-mode-comment :foreground "#5B6268"))

;; Org Noter Configuration
(setq org-noter-window-location 'vertical)
