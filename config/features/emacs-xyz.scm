(define-module (config features emacs-xyz)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (guix gexp)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (rde features emacs)
  #:use-module (config packages)
  #:export (feature-emacs-evil
            feature-emacs-leader-keys
            feature-emacs-files
            feature-emacs-syntax
            feature-emacs-corfu
            ;; feature-emacs-lang-base
            ;; feature-emacs-lang-javascript
            ))

;; (define* (feature-emacs-lang-base)
;;   "Configure Emacs for programming."
;;   (define emacs-f-name 'lang-base)
;;   (define f-name (symbol-append 'emacs- emacs-f-name))

;;   (define emacs-configure-lsp
;;     ((@@ (rde features emacs) rde-emacs-configuration-package)
;;      'rde-lsp
;;      `((eval-when-compile (require 'eglot))
;;        (with-eval-after-load
;;         'eglot
;;         (defvar eglot-command-map
;;           (let ((map (make-sparse-keymap)))
;;             (define-key map (kbd "S") '("Start" . eglot))
;;             (define-key map (kbd "R") '("Reconnect" . eglot-reconnect))
;;             (define-key map (kbd "k") '("Shutdown" . eglot-shutdown))
;;             (define-key map (kbd "K") '("Shutdown (all)" . eglot-shutdown-all))
;;             (define-key map (kbd "r") '("Rename symbol" . eglot-rename))
;;             (define-key map (kbd "f") '("Format buffer or region" . eglot-format))
;;             (define-key map (kbd "c") '("Code actions" . eglot-code-actions))
;;             (define-key map (kbd "h") '("Help" . eldoc))
;;             map)
;;           "Keymap for eglot.")
;;         (fset 'eglot-command-map eglot-command-map)
;;         (define-key eglot-mode-map (kbd "C-c c") '("code" . eglot-command-map))
;;         (define-key eglot-mode-map (kbd "C-c .") '("code actions" . eglot-code-actions))
;;         (define-key eglot-mode-map (kbd "M-,") '("Go back" . xref-go-back))
;;         (define-key eglot-mode-map (kbd "M-.") '("Go forward" . xref-go-forward))
;;         (define-key eglot-mode-map (kbd "m-<return>") '("Go to definition" . xref-find-definitions))))
;;      #:elisp-packages (list emacs-eglot)
;;      #:summary "Basic LSP configuration using eglot."))

;;   (define emacs-configure-capf
;;     ((@@ (rde features emacs) rde-emacs-configuration-package)
;;      'rde-capf
;;      `((eval-when-compile (require 'corfu))
;;        (with-eval-after-load
;;         'corfu
;;         (setq corfu-auto t
;;               corfu-quit-no-match 'separator
;;               tab-always-indent 'complete)))
;;      #:elisp-packages (list emacs-corfu)
;;      #:summary "Basic CAPF configuration using corfu."))

;;   (define emacs-configure-capf-doc
;;     ((@@ (rde features emacs) rde-emacs-configuration-package)
;;      'rde-capf-doc
;;      `((eval-when-compile (require 'corfu-doc))
;;        (with-eval-after-load
;;         'corfu-doc
;;         (define-key corfu-map (kbd "M-p") 'corfu-doc-scroll-down)
;;         (define-key corfu-map (kbd "M-n") 'corfu-doc-scroll-up)
;;         (define-key corfu-map (kbd "M-d") 'corfu-doc-toggle)))
;;      #:elisp-packages (list emacs-corfu-doc)
;;      #:summary "Basic configuration for showing CAPF docs using corfu-doc."))

;;   (feature
;;    (name f-name)
;;    (values (make-feature-values
;;             emacs-configure-lsp
;;             emacs-configure-capf
;;             emacs-configure-capf-doc))))


;; (define* (feature-emacs-lang-javascript
;;           #:key
;;           (lsp? #t)
;;           (capf? #t)
;;           (doc? #t))
;;   "Configure Emacs for JavaScript and TypeScript."
;;   (ensure-pred boolean? lsp?)
;;   (ensure-pred boolean? capf?)
;;   (ensure-pred boolean? doc?)

;;   (define emacs-f-name 'lang-javascript)
;;   (define f-name (symbol-append 'emacs- emacs-f-name))

;;   (define (get-home-services config)
;;     (list
;;      (rde-elisp-configuration-service
;;       emacs-f-name
;;       config
;;       `((eval-when-compile
;;          (require 'js)
;;          (require 'js2-mode)
;;          (require 'typescript-mode)
;;          (require 'npm-mode))

;;         ;; electric-pair-mode
;;         (defun rde--setup-electric-pairs-for-jsx-tsx ()
;;           (electric-pair-local-mode)
;;           (setq-local electric-pair-pairs
;;                       (append electric-pair-pairs
;;                               '((60 . 62)))) ;; <, >
;;           (setq-local electric-pair-text-pairs electric-pair-pairs))

;;         ;; js-mode
;;         (with-eval-after-load
;;          'js
;;          (add-hook 'js-mode-hook
;;                    (lambda ()
;;                      (rde--setup-electric-pairs-for-jsx-tsx)
;;                      (js2-minor-mode)
;;                      (npm-mode))))

;;         ;; js2-mode
;;         (with-eval-after-load
;;          'js2-mode
;;          (add-hook 'js2-minor-mode-hook 'js2-refactor-mode)
;;          (setq js-chain-indent t
;;                js2-basic-offset 2
;;                js2-skip-preprocessor-directives t
;;                js2-mode-show-parse-errors nil
;;                js2-mode-show-strict-warnings nil
;;                js2-strict-missing-semi-warning nil
;;                js2-highlight-level 3
;;                js2-idle-timer-delay 0.15))

;;         ;; typescript-mode
;;         (with-eval-after-load
;;          'typescript-mode
;;          (add-hook 'typescript-mode-hook 'npm-mode)
;;          (setq typescript-indent-level 2))

;;         ;; typescript-tsx-mode
;;         (when (fboundp 'web-mode)
;;           (define-derived-mode typescript-tsx-mode web-mode "TypeScript[TSX]")
;;           (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode)))
;;         (with-eval-after-load
;;          'web-mode
;;          (setq web-mode-markup-indent-offset 2
;;                web-mode-css-indent-offset 2
;;                web-mode-code-indent-offset 2)
;;          (add-hook 'typescript-tsx-mode-hook
;;                    (lambda ()
;;                      (rde--setup-electric-pairs-for-jsx-tsx)
;;                      (npm-mode))))

;;         ;; npm-mode
;;         (with-eval-after-load
;;          'npm-mode
;;          (fset 'npm-mode-command-keymap npm-mode-command-keymap)
;;          (define-key npm-mode-keymap (kbd "C-c n") '("npm" . npm-mode-command-keymap)))

;;         ;; js2-refactor-el
;;         ;; TODO: add js2r keybindings
;;         ;; (js2r-add-keybindings-with-prefix "C-c r")
;;         ;; (define-key js2-refactor-mode-map (kbd "C-c r f") 'js2r-extract-function)

;;         ,@(when lsp? ;; eglot configuration
;;             `((require 'configure-rde-lsp)
;;               (eval-when-compile (require 'eglot))
;;               (with-eval-after-load
;;                'eglot
;; 	       (add-to-list 'eglot-server-programs
;;                             '(typescript-tsx-mode . ("typescript-language-server" "--stdio"))))
;;               (dolist (hook
;;                        '(js-mode-hook
;;                          typescript-mode-hook
;;                          typescript-tsx-mode-hook))
;;                       (add-hook hook
;;                                 (lambda ()
;;                                   (eglot-ensure)
;;                                   (eglot--code-action eglot-code-action-organize-imports-ts "source.organizeImports.ts")
;;                                   (eglot--code-action eglot-code-action-add-missing-imports-ts "source.addMissingImports.ts")
;;                                   (eglot--code-action eglot-code-action-removed-unused-ts "source.removedUnused.ts")
;; 		                  (eglot--code-action eglot-code-action-fix-all-ts "source.fixAll.ts")
;;                                   (local-set-key (kbd "C-c c i") '("Add missing imports" . eglot-code-action-add-missing-imports-ts))
;;                                   (local-set-key (kbd "C-c c o") '("Organize imports" . eglot-code-action-organize-imports-ts))
;;                                   (local-set-key (kbd "C-c c r") '("Remove unused symbols" . eglot-code-action-removed-unused-ts))
;;                                   (local-set-key (kbd "C-c c f") '("Fix all" . eglot-code-action-fix-all-ts)))))))

;;         ,@(when capf? ;; corfu configuration
;;             `((require 'configure-rde-capf)
;;               (add-hook 'js-mode-hook 'corfu-mode)
;;               (add-hook 'typescript-mode-hook 'corfu-mode)
;;               (add-hook 'typescript-tsx-mode-hook 'corfu-mode)
;;               ,@(when doc?
;;                   `((require 'configure-rde-capf-doc)
;;                     (add-hook 'js-mode-hook 'corfu-doc-mode)
;;                     (add-hook 'typescript-mode-hook 'corfu-doc-mode)
;;                     (add-hook 'typescript-tsx-mode-hook 'corfu-doc-mode))))))
;;       #:elisp-packages (list emacs-js2-mode
;;                              emacs-js2-refactor-el
;;                              emacs-typescript-mode
;;                              emacs-npm-mode
;;                              emacs-web-mode ;; TODO: Move to emacs-feature-lang-web?
;;                              (when lsp? (get-value 'emacs-configure-lsp config))
;;                              (when capf? (get-value 'emacs-configure-capf config))
;;                              (when doc? (get-value 'emacs-configure-capf-doc config))))))
;;   (feature
;;    (name f-name)
;;    (values `((,f-name . #t)))
;;    (home-services-getter get-home-services)))


;; (define emacs-configure-capf
;;   ((@@ (rde features emacs) rde-emacs-configuration-package)
;;    'rde-capf
;;    `((eval-when-compile (require 'corfu))
;;      (with-eval-after-load
;;       'corfu
;;       (setq corfu-auto t
;;             corfu-quit-no-match 'separator
;;             tab-always-indent 'complete)))
;;    #:elisp-packages (list emacs-corfu)
;;    #:summary "Basic CAPF configuration using corfu."))

(define* (feature-emacs-corfu
          #:key
          (emacs-corfu emacs-corfu)
          (emacs-corfu-doc #f))
  "Basic CAPF configuration using corfu."
  
  (define emacs-f-name 'corfu)
  (define f-name (symbol-append 'emacs- emacs-f-name))

  (define (get-home-services config)
    (list
     (rde-elisp-configuration-service
      emacs-f-name
      config
      `((with-eval-after-load
         'corfu
         (setq corfu-auto t
               corfu-quit-no-match 'separator
               tab-always-indent 'complete))
        ,@(if emacs-corfu-doc
            '((with-eval-after-load
               'corfu-doc
               (define-key corfu-map (kbd "M-p") 'corfu-doc-scroll-down)
               (define-key corfu-map (kbd "M-n") 'corfu-doc-scroll-up)
               (define-key corfu-map (kbd "M-d") 'corfu-doc-toggle)))
            '()))
      #:elisp-packages (append
                        (list emacs-corfu)
                        (if emacs-corfu-doc
                            (list (get-value 'emacs-corfu-doc config))
                            '())))))
  (feature
   (name f-name)
   (values (append
            `((,f-name . ,emacs-corfu))
            (if emacs-corfu-doc
                `((emacs-corfu-doc . ,emacs-corfu-doc))
                '())))
   (home-services-getter get-home-services)))

(define* (feature-emacs-evil)
  "Configure evil-mode in Emacs."
  (define emacs-f-name 'evil)
  (define f-name (symbol-append 'emacs- emacs-f-name))

  (define (get-home-services config)
    (list
     (rde-elisp-configuration-service
      emacs-f-name
      config
      `((eval-when-compile (require 'evil))
        (setq evil-want-keybinding nil
              evil-want-fine-undo t)
        (evil-mode 1)

        ;; Keybindings
        (with-eval-after-load
         'evil
         (evil-define-key 'normal prog-mode-map (kbd "<tab>") 'evil-jump-item)
         (define-key evil-normal-state-map (kbd "M-.") nil)
         (define-key evil-normal-state-map (kbd "M-,") nil)
         (define-key evil-normal-state-map (kbd "C-.") nil)

        ;; V for evil-visual-line in magit
        ,@(when (get-value 'emacs-git config)
            `((with-eval-after-load
	       'magit
	       (define-key magit-hunk-section-map (kbd "V") 'evil-visual-line))))

        ;; Start vterm in insert mode
        ,@(when (get-value 'emacs-vterm config)
            `((add-to-list 'evil-insert-state-modes 'vterm-mode)))))
      #:elisp-packages (list emacs-evil))))

  (feature
   (name f-name)
   (values `((,f-name . #t)))
   (home-services-getter get-home-services)))

(define* (feature-emacs-syntax)
  "Configure multiple packages for working better
with Emacs as an editor."
  (define emacs-f-name 'syntax)
  (define f-name (symbol-append 'emacs- emacs-f-name))

  (define (get-home-services config)
    (list
     (rde-elisp-configuration-service
      emacs-f-name
      config
      `((eval-when-compile (require 'smartparens-config))
        (add-hook 'prog-mode-hook 'smartparens-mode)
        (with-eval-after-load
         'smartparens
         (define-key smartparens-mode-map (kbd "M-<up>") 'sp-backward-up-sexp)
         (define-key smartparens-mode-map (kbd "M-<down>") 'sp-down-sexp)
         (define-key smartparens-mode-map (kbd "M-<left>") 'sp-backward-sexp)
         (define-key smartparens-mode-map (kbd "M-<right>") 'sp-next-sexp))

        ;; smart-hungry-delete
        (eval-when-compile (require 'smart-hungry-delete))
        (smart-hungry-delete-add-default-hooks)
        (normal-erase-is-backspace-mode 0)
        (define-key prog-mode-map (kbd "M-DEL") 'smart-hungry-delete-forward-char)
        (define-key prog-mode-map (kbd "M-<delete>") 'smart-hungry-delete-backward-char))
      #:elisp-packages (list emacs-smartparens
                             emacs-smart-hungry-delete))))

  (feature
   (name f-name)
   (values `((,f-name . #t)))
   (home-services-getter get-home-services)))

(define* (feature-emacs-files)
  "Configure leader and localleader keys"
  (define emacs-f-name 'files)
  (define f-name (symbol-append 'emacs- emacs-f-name))

  (define (get-home-services config)
    (list
     (rde-elisp-configuration-service
      emacs-f-name
      config
      `((require 'tramp)
        (defun rde-delete-this-file (&optional path force-p)
          "Delete PATH, kill its buffers and expunge it from vc/magit cache.
If PATH is not specified, default to the current buffer's file.
If FORCE-P, delete without confirmation."
          (interactive
           (list (buffer-file-name (buffer-base-buffer))
                 current-prefix-arg))
          (let* ((path (or path (buffer-file-name (buffer-base-buffer))))
                 (short-path (abbreviate-file-name path)))
            (unless (and path (file-exists-p path))
              (user-error "Buffer is not visiting any file"))
            (unless (file-exists-p path)
              (error "File doesn't exist: %s" path))
            (unless (or force-p (y-or-n-p (format "Really delete %S?" short-path)))
              (user-error "Aborted"))
            (let ((buf (current-buffer)))
              (unwind-protect
               (progn (delete-file path t) t)
               (if (file-exists-p path)
                   (error "Failed to delete %S" short-path)
                   (kill-this-buffer)
                   (message "Deleted %S" short-path))))))

        ;;; Source: https://github.com/hlissner/doom-emacs/blob/develop/core/autoload/files.el#L257
        (defun rde-copy-this-file (new-path &optional force-p)
          "Copy current buffer's file to NEW-PATH.
If FORCE-P, overwrite the destination file if it exists, without confirmation."
          (interactive
           (list (read-file-name "Copy file to: ")
                 current-prefix-arg))
          (unless (and buffer-file-name (file-exists-p buffer-file-name))
            (user-error "Buffer is not visiting any file"))
          (let ((old-path (buffer-file-name (buffer-base-buffer)))
                (new-path (expand-file-name new-path)))
            (make-directory (file-name-directory new-path) 't)
            (copy-file old-path new-path (or force-p 1))
            (message "File copied to %S" (abbreviate-file-name new-path))))

        ;;; Source: https://github.com/hlissner/doom-emacs/blob/develop/core/autoload/files.el#L274
        (defun rde-move-this-file (new-path &optional force-p)
          "Move current buffer's file to NEW-PATH.
If FORCE-P, overwrite the destination file if it exists, without confirmation."
          (interactive
           (list (read-file-name "Move file to: ")
                 current-prefix-arg))
          (unless (and buffer-file-name (file-exists-p buffer-file-name))
            (user-error "Buffer is not visiting any file"))
          (let ((old-path (buffer-file-name (buffer-base-buffer)))
                (new-path (expand-file-name new-path)))
            (when (directory-name-p new-path)
              (setq new-path (concat new-path (file-name-nondirectory old-path))))
            (make-directory (file-name-directory new-path) 't)
            (rename-file old-path new-path (or force-p 1))
            (set-visited-file-name new-path t t)
            (message "File moved to %S" (abbreviate-file-name new-path))))

        ;;; Source: https://github.com/hlissner/doom-emacs/blob/develop/core/autoload/files.el#L293
        (defun rde--sudo-file-path (file)
          (let ((host (or (file-remote-p file 'host) "localhost")))
            (concat "/" (when (file-remote-p file)
                          (concat (file-remote-p file 'method) ":"
                                  (if-let (user (file-remote-p file 'user))
                                          (concat user "@" host)
                                          host)
                                  "|"))
                    "sudo:root@" host
                    ":" (or (file-remote-p file 'localname)
                            file))))

        ;;; Source: https://github.com/hlissner/doom-emacs/blob/develop/core/autoload/files.el#L306
        (defun rde-sudo-find-file (file)
          "Open FILE as root."
          (interactive "FOpen file as root: ")
          (find-file (rde--sudo-file-path file)))

        ;;; Source: https://github.com/hlissner/doom-emacs/blob/develop/core/autoload/files.el#L312
        (defun rde-sudo-this-file ()
          "Open the current file as root."
          (interactive)
          (find-file
           (rde--sudo-file-path
            (or buffer-file-name
                (when (or (derived-mode-p 'dired-mode)
                          (derived-mode-p 'wdired-mode))
                  default-directory)))))

        (defun rde-yank-buffer-path ()
          "Copy the current buffer file name to the clipboard."
          (interactive)
          (let ((filename (if (equal major-mode 'dired-mode)
                              default-directory
                              (buffer-file-name))))
            (when filename
              (kill-new filename)
              (message "Copied buffer file name '%s' to the clipboard." filename))))
        
        (defvar rde-files-command-map
          (let ((map (make-sparse-keymap)))
            ;; C-x C-f -> find-file
            ;; C-x d -> dired
            (define-key map (kbd "d") '("Delete this file" . rde-delete-this-file))
            (define-key map (kbd "c") '("Copy this file" . rde-copy-this-file))
            (define-key map (kbd "m") '("Move this file" . rde-move-this-file))
            (define-key map (kbd "u") '("Sudo this file" . rde-sudo-this-file))
            (define-key map (kbd "U") '("Sudo find file" . rde-sudo-find-file))
            map)
          "Keymap for working with files.")
        (fset 'rde-files-command-map rde-files-command-map)
        (define-key global-map (kbd "C-c f") '("files" . rde-files-command-map)))
      #:elisp-packages
      (append (list (get-value 'emacs-configure-rde-keymaps config))))))

  (feature
   (name f-name)
   (values `((,f-name . #t)))
   (home-services-getter get-home-services)))
