;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Base Configuration
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Security Settings
(setq auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry nil)  ; Cache credentials

;; Performance Optimizations
(setq gc-cons-threshold 100000000
      read-process-output-max (* 1024 1024))

;; Theme and Visual Settings
(setq doom-theme 'doom-one
      display-line-numbers-type t
      doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq-default truncate-lines nil)

;; Directory Structure
(setq org-directory "~/synthesis/org/"
      default-directory "~/synthesis/go/")

;; Whitespace Configuration
(setq whitespace-style '(face tabs spaces trailing lines-tail newline empty 
                        indentation space-after-tab space-before-tab))

;; LSP Performance and Security Settings
(after! lsp-mode
  (setq lsp-enable-file-watchers nil  ; Disable file watchers for better performance
        lsp-file-watch-threshold 5000
        lsp-idle-delay 0.5
        lsp-log-io nil  ; Disable logging for security
        lsp-completion-provider :capf
        lsp-keymap-prefix "C-c l"))

;; Go Development Environment Configuration
(use-package! go-mode
  :hook ((go-mode . lsp-deferred)
         (go-mode . company-mode)
         (go-mode . yas-minor-mode)
         (before-save . lsp-format-buffer)
         (before-save . lsp-organize-imports))
  :config
  (require 'lsp-go)
  
  ;; Security: Disable automatic execution
  (setq go-generate-in-save-hook nil)
  
  ;; Go tools setup
  (setq gofmt-command "gofumpt"
        go-test-verbose t))

;; Enhanced LSP Configuration for Go
(after! lsp-mode
  (setq lsp-go-analyses
        '((fieldalignment . t)
          (nilness . t)
          (shadow . t)
          (unusedparams . t)
          (unusedwrite . t)
          (useany . t))
        lsp-go-codelenses
        '((gc_details . t)
          (generate . t)
          (regenerate_cgo . t)
          (tidy . t)
          (upgrade_dependency . t)
          (vendor . t))
        lsp-go-use-gofumpt t
        lsp-go-use-placeholders t
        lsp-go-link-target "pkg.go.dev"
        lsp-go-import-shortcut "Link"))

;; Company Mode Configuration
(use-package! company
  :config
  (setq company-idle-delay 0
        company-minimum-prefix-length 1
        company-tooltip-limit 14
        company-tooltip-align-annotations t
        company-require-match 'never))

;; Treemacs Configuration
(after! treemacs
  (setq treemacs-position 'left
        treemacs-width 35
        treemacs-show-hidden-files t
        treemacs-follow-after-init t
        treemacs-project-follow-cleanup t
        treemacs-git-mode 'deferred)
  
  ;; Security: Ignore sensitive directories
  (setq treemacs-ignored-file-predicates
        (append treemacs-ignored-file-predicates
                '((lambda (file _) 
                    (string-match-p 
                     (rx (or ".git" "node_modules" "vendor" ".env")) file)))))
  
  ;; Create and setup Go workspace
  (treemacs-create-workspace "Go Projects")
  (treemacs-add-and-display-current-project-exclusively))

;; Projectile Configuration
(after! projectile
  (setq projectile-project-search-path '("~/synthesis/go/")
        projectile-indexing-method 'alien
        projectile-enable-caching t
        projectile-auto-discover t)
  
  (projectile-register-project-type 'go
                                  '("go.mod")
                                  :project-file "go.mod"
                                  :compile "go build"
                                  :test "go test ./..."
                                  :run "go run ."
                                  :test-suffix "_test"))

;; DAP Mode for Debugging
(use-package! dap-mode
  :after lsp-mode
  :config
  (dap-mode t)
  (dap-ui-mode t)
  (require 'dap-go)
  (dap-go-setup))

;; Key Bindings
(map! :leader
      ;; Go workspace bindings
      (:prefix ("o" . "open")
       :desc "Open Go workspace" "g" #'open-go-workspace)
      (:prefix ("p" . "project")
       :desc "Go workspace root" "g" (cmd! (cd "~/synthesis/go/"))))

;; Enhanced Go Mode Key Bindings
(map! :map go-mode-map
      :leader
      (:prefix ("m" . "mode")
       (:prefix ("t" . "test")
        "t" #'go-test-current-test
        "f" #'go-test-current-file
        "p" #'go-test-current-project)
       (:prefix ("g" . "go")
        "i" #'go-goto-imports
        "f" #'go-fill-struct
        "a" #'go-tag-add
        "r" #'go-tag-remove
        "d" #'lsp-find-definition
        "r" #'lsp-find-references
        "h" #'lsp-describe-thing-at-point
        "R" #'lsp-rename)))

;; Org Mode Configuration
(after! org
  (setq org-startup-folded 'content
        org-startup-with-inline-images t)
  
  ;; Header Sizes
  (custom-set-faces!
    '(org-level-1 :inherit outline-1 :height 1.5 :weight bold)
    '(org-level-2 :inherit outline-2 :height 1.4 :weight bold)
    '(org-level-3 :inherit outline-3 :height 1.3 :weight semi-bold)
    '(org-level-4 :inherit outline-4 :height 1.2 :weight semi-bold)
    '(org-level-5 :inherit outline-5 :height 1.1 :weight normal)
    '(org-level-6 :inherit outline-6 :height 1.1 :weight normal)
    '(org-level-7 :inherit outline-7 :height 1.1 :weight normal)
    '(org-level-8 :inherit outline-8 :height 1.1 :weight normal)))

;; Org Noter Configuration
(setq org-noter-window-location 'vertical)

;; Custom Functions
(defun open-go-workspace ()
  "Open the Go workspace in Treemacs."
  (interactive)
  (treemacs-select-window)
  (cd "~/synthesis/go/")
  (treemacs-add-and-display-current-project-exclusively))

;; Theme Customizations
(custom-set-faces!
  '(go-mode-keyword :foreground "#51afef")
  '(go-mode-function-name :foreground "#98be65")
  '(go-mode-string :foreground "#98be65")
  '(go-mode-comment :foreground "#5B6268"))
