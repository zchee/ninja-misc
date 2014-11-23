;;; ninja-mode.el --- Major mode for editing .ninja files

;; Copyright 2011 Google Inc. All Rights Reserved.
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

;;; Commentary:

;; Simple emacs mode for editing .ninja files.
;; Just some syntax highlighting for now.

;;; Code:

(defvar ninja-keywords
  `((,(concat "^" (regexp-opt '("rule" "build" "subninja" "include"
                                "pool" "default")
                              'words))
     . font-lock-keyword-face)
    ("\\([[:alnum:]_]+\\) =" . (1 font-lock-variable-name-face))
    ;; Variable expansion.
    ("$[[:alnum:]_]+" . font-lock-variable-name-face)
    ("${[[:alnum:]._]+}" . font-lock-variable-name-face)
    ;; Rule names
    ("rule +\\([[:alnum:]_.-]+\\)" . (1 font-lock-function-name-face))
    ;; Build Statement - highlight the rule used,
    ;; allow for escaped $,: in outputs.
    ("build +\\(?:[^:$\n]\\|$[:$]\\)+ *: *\\([[:alnum:]_.-]+\\)" .
     (1 font-lock-function-name-face))))

(defvar ninja-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\" "." table)
    table)
  "Syntax table used in `ninja-mode'.")

(defun ninja-syntax-propertize (start end)
  (save-match-data
    (save-excursion
      (goto-char start)
      (while (search-forward "#" end t)
        (let ((match-pos (match-beginning 0)))
          (when (and
                 ;; Is it the first non-white character on the line?
                 (eq match-pos (save-excursion (back-to-indentation) (point)))
                 ;; Are we *not* continuing the previous line?
                 (not (eq ?$ (char-before (line-end-position 0)))))
            (put-text-property match-pos (1+ match-pos) 'syntax-table '(11))
            (let ((line-end (line-end-position)))
              (put-text-property line-end (1+ line-end) 'syntax-table '(12)))))))))

;;;###autoload
(define-derived-mode ninja-mode prog-mode "ninja"
  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'parse-sexp-lookup-properties) t)
  (set (make-local-variable 'syntax-propertize-function) #'ninja-syntax-propertize)
  (setq font-lock-defaults '(ninja-keywords)))

;; Run ninja-mode for files ending in .ninja.
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ninja$" . ninja-mode))

(provide 'ninja-mode)

;;; ninja-mode.el ends here
