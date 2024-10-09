(setq inhibit-starup-message t)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

(add-to-list 'default-frame-alist '(fullscreen . fullboth))

(scroll-bar-mode 0)
(tool-bar-mode 0)
(tooltip-mode 0)
(menu-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)

(ido-mode 1)
(ido-everywhere 1)

(recentf-mode 1)
(global-set-key "\C-xf" 'recentf-open-files) ;; C-x+f to open recent buffers

(setq use-dialog-box nil ;; prevent pop up UI dialogs
      confirm-kill-processes nil)

(setq-default indent-tabs-mode nil ;; proper tabs
              tab-width 4)

(global-auto-revert-mode 1) ;; Revert buffers when underlying file has changed on disc
(setq global-auto-revert-non-file-buffers t) ;; And do the same for dired

(setq history-length 25) ;; proper history
(savehist-mode 1)
(save-place-mode 1)

(setq make-backup-files nil ;; Prevent creation of backup files
      create-lockfiles nil) ;; Prevent creation of lock files

(setq display-line-numbers-type 'relative) ;; relative line numbers
(global-display-line-numbers-mode)

(dolist (mode '(org-mode-hook ;; except for terminal buffers
        term-mode-hook
        eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))


(add-to-list 'default-frame-alist '(font . "Iosevka-20"))
(load-theme 'gruber-darker :no-confirm)

(add-hook 'before-save-hook 'whitespace-cleanup) ;; Clear whitespace when saving file

;; Initialize package sources
(require 'package)

(setq package-archives '(
             ("melpa-stable" . "https://stable.melpa.org/packages/")
             ("elpa" . "https://elpa.gnu.org/packages/")

))
(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

(unless (package-installed-p 'use-package)
   (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Setup ivy
(use-package swiper)
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")

(use-package counsel)
(setq counsel-grep-base-command
 "rg -i -M 120 --no-heading --line-number --color never '%s' %s")

;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Vim motions
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t) ;; C-u/d scrolling
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-escape
  :after evil
  :diminish
  :config
  (setq-default evil-escape-key-sequence "kj")
  :init
  (evil-escape-mode))

(use-package evil-leader
  :after evil
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "SPC")
  (evil-leader/set-key
    "." 'counsel-find-file
    "," 'counsel-switch-buffer
    "fr" 'counsel-recentf
    "bs" 'save-buffer
    "bp" 'previous-buffer
    "bn" 'next-buffer
    "bk" (lambda ()
             (interactive)
             (kill-buffer (current-buffer)))
    "ws" 'evil-window-split
    "wv" 'evil-window-vsplit
    "wc" 'evil-window-delete
    "hf" 'counsel-describe-function
    "hv" 'counsel-describe-variable
    "h." 'describe-symbol
    "sb" 'swiper
    "sd" 'counsel-rg
    "sg" 'counsel-git-grep
  ))
(define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)

(use-package simpleclip)
(simpleclip-mode 1) ;; os clipboard copy paste with <s>-c/v

(use-package magit)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))
(setq dired-listing-switches "-alvh")

(use-package ivy-prescient
  :after counsel
  :config
  (ivy-prescient-mode 1))
(setq prescient-filter-method '(literal regexp fuzzy))

;; LSP-Mode Requires upgrade to emacs27.1
(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l"))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
              ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package python-mode
  :ensure nil
  :hook (python-mode . lsp-deferred)
  :custom
  (python-shell-interpreter "python3"))
