(define-module (config features javascript)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages node)
  #:use-module (config packages node-xyz)
  #:use-module (config features emacs-xyz)
  #:use-module (emacs packages melpa)
  #:use-module (rde features)
  #:use-module (rde features emacs)
  #:use-module (rde features predicates)
  #:use-module (guix gexp)
  #:use-module (ice-9 pretty-print)
  #:export (feature-javascript))

(define* (feature-javascript
          #:key
          (typescript #f)
          (typescript-language-server #f)
          (eslint #f))
  "Setup and configure environment for JavaScript."
  (ensure-pred maybe-file-like? typescript)
  (ensure-pred maybe-file-like? typescript-language-server)
  (ensure-pred maybe-file-like? eslint)

  (define (get-home-services config)
    (define emacs-f-name 'javascript)
    (define tsserver-library
      (if (any-package? typescript)
          (file-append typescript "/lib/")
          typescript))
    (define ts-lsp-executable
      (if (any-package? typescript-language-server)
          (file-append typescript-language-server
                       "/bin/typescript-language-server")
          typescript-language-server))
    (define eslint-executable
      (if (any-package? eslint)
          (file-append eslint "/bin/eslint")
          eslint))
    (list
     (when (get-value 'emacs config)
       (rde-elisp-configuration-service
        emacs-f-name
        config
        `(;;; TODO: Remove after https://github.com/joaotavora/eglot/pull/871 is merged.
          (eval-when-compile (require 'eglot))
          ;; electric-pair-mode
          (defun rde--setup-electric-pairs-for-jsx-tsx ()
            (electric-pair-local-mode)
            (setq-local electric-pair-pairs
                        (append electric-pair-pairs
                                '((60 . 62)))) ;; <, >
            (setq-local electric-pair-text-pairs electric-pair-pairs))

          ;; js-mode
          (with-eval-after-load
           'js
           (add-hook 'js-mode-hook
                     (lambda ()
                       (rde--setup-electric-pairs-for-jsx-tsx)
                       (js2-minor-mode)
                       (npm-mode))))

          ;; js2-mode
          (with-eval-after-load
           'js2-mode
           ;;(add-hook 'js2-minor-mode-hook 'js2-refactor-mode)
           (setq js-chain-indent t
                 js2-basic-offset 2
                 js2-skip-preprocessor-directives t
                 js2-mode-show-parse-errors nil
                 js2-mode-show-strict-warnings nil
                 js2-strict-missing-semi-warning nil
                 js2-highlight-level 3
                 js2-idle-timer-delay 0.15))

          ;; typescript-mode
          (with-eval-after-load
           'typescript-mode
           (add-hook 'typescript-mode-hook 'npm-mode)
           (setq typescript-indent-level 2))

          ;; typescript-tsx-mode
          (when (fboundp 'web-mode)
            (define-derived-mode typescript-tsx-mode web-mode "TypeScript[TSX]")
            (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode)))
          (with-eval-after-load
           'web-mode
           (setq web-mode-markup-indent-offset 2
                 web-mode-css-indent-offset 2
                 web-mode-code-indent-offset 2)
           (add-hook 'typescript-tsx-mode-hook
                     (lambda ()
                       (rde--setup-electric-pairs-for-jsx-tsx)
                       (npm-mode))))

          ;; jsdoc
          ;; TODO: Implement after https://issues.guix.gnu.org/issue/49946 is merged.

          ;; npm-mode
          (with-eval-after-load
           'npm-mode
           (fset 'npm-mode-command-keymap npm-mode-command-keymap)
           (define-key npm-mode-keymap (kbd "C-c n") '("npm" . npm-mode-command-keymap)))

          ;; js2-refactor-el
          ;; TODO: add js2r keybindings
          ;; (js2r-add-keybindings-with-prefix "C-c r")
          ;; (define-key js2-refactor-mode-map (kbd "C-c r f") 'js2r-extract-function)

          ;; eglot
          (with-eval-after-load
           'eglot
           ;;; TODO: Remove after https://github.com/joaotavora/eglot/pull/871 is merged.
           (eglot--code-action eglot-code-action-organize-imports-ts "source.organizeImports.ts")
           (eglot--code-action eglot-code-action-add-missing-imports-ts "source.addMissingImports.ts")
           (eglot--code-action eglot-code-action-removed-unused-ts "source.removedUnused.ts")
	   (eglot--code-action eglot-code-action-fix-all-ts "source.fixAll.ts")

           ;; keybindings
           (defvar eglot-command-map
             (let ((map (make-sparse-keymap)))
               (define-key map (kbd "S") '("Start" . eglot))
               (define-key map (kbd "R") '("Reconnect" . eglot-reconnect))
               (define-key map (kbd "k") '("Shutdown" . eglot-shutdown))
               (define-key map (kbd "K") '("Shutdown (all)" . eglot-shutdown-all))
               (define-key map (kbd "r") '("Rename symbol" . eglot-rename))
               (define-key map (kbd "f") '("Format buffer or region" . eglot-format))
               (define-key map (kbd "c") '("Code actions" . eglot-code-actions))
               (define-key map (kbd "h") '("Help" . eldoc))
               map)
             "Keymap for eglot.")
           (fset 'eglot-command-map eglot-command-map)
           (define-key eglot-mode-map (kbd "C-c c") '("code" . eglot-command-map))
           (define-key eglot-mode-map (kbd "M-RET") '("code actions" . eglot-code-actions))
           (define-key eglot-mode-map (kbd "M-,") '("Go a ref backward" . xref-go-back))
           (define-key eglot-mode-map (kbd "M-.") '("Go a ref forward" . xref-go-forward))
           (define-key eglot-mode-map (kbd "C-.") '("Go to definition" . xref-find-definitions))

           ;; We need to add other flymake checkers
           ;; Therefore disable automatic integration
           (add-to-list 'eglot-stay-out-of 'flymake)
           (add-hook 'flymake-diagnostic-functions 'eglot-flymake-backend nil t)
           (add-hook 'eglot-managed-mode-hook (lambda () (flymake-mode t)))

           (add-to-list 'eglot-server-programs
                        '((js-mode
                           typescript-mode
                           typescript-tsx-mode) . (,ts-lsp-executable
                                                   "--tsserver-path" ,tsserver-library
                                                   "--stdio"))))
          ;; general
          (dolist (hook
                   '(js-mode-hook
                     typescript-mode-hook
                     typescript-tsx-mode-hook))
                  (add-hook hook
                            (lambda ()
                              (eglot-ensure)
                              ,@(if (get-value 'emacs-corfu config)
                                    '((corfu-mode)) '())
                              ,@(if (get-value 'emacs-corfu-doc config)
                                    '((corfu-doc-mode)) '())
                              ,@(if eslint
                                    '((require 'flymake-eslint)
                                      (add-hook 'flymake-diagnostic-functions 'flymake-eslint--checker nil t)
                                      (local-set-key (kbd "M-C-S-p") '(lambda ()
                                                                        (interactive)
                                                                        (save-buffer)
                                                                        (eslint-fix))))
                                    '())
                              (local-set-key (kbd "C-c c i") '("Add missing imports" . eglot-code-action-add-missing-imports-ts))
                              (local-set-key (kbd "C-c c o") '("Organize imports" . eglot-code-action-organize-imports-ts))
                              (local-set-key (kbd "C-c c r") '("Remove unused symbols" . eglot-code-action-removed-unused-ts))
                              (local-set-key (kbd "C-c c f") '("Fix all" . eglot-code-action-fix-all-ts)))))
          ,@(if eslint
                `((with-eval-after-load
                   'flymake-eslint
                   (setq flymake-eslint-executable-name ,eslint-executable))
                  (with-eval-after-load
                   'eslint-fix
                   (setq eslint-fix-executable ,eslint-executable)))
                '()))
        #:elisp-packages (append
                          (if (get-value 'emacs-corfu config)
                              (list (get-value 'emacs-corfu config))
                              '())
                          (if (get-value 'emacs-corfu-doc config)
                              (list (get-value 'emacs-corfu-doc config))
                              '())
                          (list emacs-js2-mode ;;emacs-js2-refactor-el
                                emacs-typescript-mode
                                emacs-npm-mode
                                emacs-web-mode
                                emacs-flymake-eslint
                                emacs-eslint-fix
                                (get-value 'emacs-eglot config emacs-eglot)))))))

  (feature
   (name 'javascript)
   (values `((javascript . #t)))
   (home-services-getter get-home-services)))
