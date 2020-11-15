;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "wgjak47"
      user-mail-address "ak47m61@gamil.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "monospace" :size 26))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; this is the spacemacs style windows select key map
(map! :leader
  "1" 'winum-select-window-1
  "2" 'winum-select-window-2
  "3" 'winum-select-window-3
  "4" 'winum-select-window-4
)

;; for treemacs
(map! (:leader (:desc "open window 0" :g "0" #'treemacs-select-window)) )

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

(use-package! keychain-environment
  :init
  (keychain-refresh-environment))

;; rime config
(use-package! rime
  :custom
  (default-input-method "rime")
  (rime-user-data-dir "/home/wgjak47/.local/share/fcitx5/rime")
  (rime-emacs-module-header-root "/usr/include/emacs-27")
  :config
  (setq
    rime-show-candidate 'posframe
    mode-line-mule-info '((:eval (rime-lighter)))
    rime-inline-ascii-trigger 'shift-l))

;; solve rime show bug
  (defun +rime--posframe-display-content-a (args)
    "给 `rime--posframe-display-content' 传入的字符串加一个全角空
格，以解决 `posframe' 偶尔吃字的问题。"
    (cl-destructuring-bind (content) args
      (let ((newresult (if (string-blank-p content)
                           content
                         (concat content "　"))))
        (list newresult))))

  (if (fboundp 'rime--posframe-display-content)
      (advice-add 'rime--posframe-display-content
                  :filter-args
                  #'+rime--posframe-display-content-a)
    (error "Function `rime--posframe-display-content' is not available."))

;; lsp-ui config
(after! lsp-ui
  (setq lsp-ui-doc-position 'at-point
        lsp-ui-doc-enable t
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-sideline-update-mode 'point
        lsp-ui-doc-enable t))

(defun spacemacs//go-enable-flycheck-golangci-lint ()
  "Enable `flycheck-golangci-linter' and disable overlapping `flycheck' linters."
  (setq flycheck-disabled-checkers '(go-gofmt
                                     go-golint
                                     go-vet
                                     ;; go-build
                                     ;; go-test
                                     go-errcheck
                                     go-staticcheck
                                     go-unconvert))
  (setq-local lsp-diagnostics-provider :none)
  (flycheck-golangci-lint-setup)


  ;; Make sure to only run golangci after go-build
  ;; to ensure we show at least basic errors in the buffer
  ;; when golangci fails. Make also sure to run go-test if possible.
  ;; See #13580 for details
  (flycheck-add-next-checker 'go-build '(warning . golangci-lint) t)
  (flycheck-add-next-checker 'go-test '(warning . golangci-lint) t)

  ;; Set basic checkers explicitly as flycheck will
  ;; select the better golangci-lint automatically.
  ;; However if it fails we require these as fallbacks.
  (cond ((flycheck-may-use-checker 'go-test) (flycheck-select-checker 'go-test))
        ((flycheck-may-use-checker 'go-build) (flycheck-select-checker 'go-build))))

;;flycheck config for golang
(add-hook 'go-mode-hook  #'spacemacs//go-enable-flycheck-golangci-lint t)


;; rust flycheck with lsp
(after! lsp-rust
  (setq lsp-rust-server 'rust-analyzer)
  (setq lsp-rust-analyzer-cargo-watch-command "clippy")
  )

;; add cargo edit key binding
(map! :map rustic-mode-map
        :localleader
        (:prefix ("b" . "build")
          :desc "cargo add"     "A" #'rustic-cargo-add
          :desc "cargo upgrade" "U" #'rustic-cargo-upgrade
          :desc "cargo rm"      "R" #'rustic-cargo-rm))
