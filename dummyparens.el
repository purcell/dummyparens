;; Boost Software License - Version 1.0 - August 17th, 2003

;; Permission is hereby granted, free of charge, to any person or organization
;; obtaining a copy of the software and accompanying documentation covered by
;; this license (the "Software") to use, reproduce, display, distribute,
;; execute, and transmit the Software, and to prepare derivative works of the
;; Software, and to permit third-parties to whom the Software is furnished to
;; do so, all subject to the following:

;; The copyright notices in the Software and this entire statement, including
;; the above license grant, this restriction and the following disclaimer,
;; must be included in all copies of the Software, in whole or in part, and
;; all derivative works of the Software, unless such copies or derivative
;; works are solely in the form of machine-executable object code generated by
;; a source language processor.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
;; SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
;; FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.

;; ABOUT: dummy parens is a simple utility providing parentheses
;; auto-pairing and wrapping behavior

(defun dp-brace-post-handler ()
  "Indents after insertion"
  (when dp-wrap
    (indent-region (car dp-wrap) (cdr dp-wrap)))
  (indent-for-tab-command))

(setq dp-pairs '(
                 ("(" ")" nil)
                 ("[" "]" nil)
                 ("{" "}" dp-brace-post-handler)
                 ("\"" "\"" dp-brace-post-handler)
                 ))

(defun dp-self-insert-command (arg)
  "This function should be binded to opening pair"
  (interactive "p")
  (if (not (region-active-p))
      ;; we're not wrapping
      (setq dp-wrap nil)
    ;; save point and mark position
    (setq dp-wrap (cons (region-beginning)
                        (1+ (region-end)))) ;; 1+ since we call self-insert next
    (goto-char (car dp-wrap)))

  ;; call self-insert-command
  (self-insert-command arg)

  (save-excursion
    ;; for each pair
    (dolist (pair dp-pairs)
      ;; test if pressed key corresponds to an opening pair
      (when (equal (single-key-description last-command-event) (car pair))
        ;; goto region end when wrapping
        (when dp-wrap
          (goto-char (cdr dp-wrap)))
        (let ((closing-pair (nth 1 pair))
              (post-handler (nth 2 pair)))
          (insert closing-pair)
          ;; run post-handler
          (when post-handler
            (funcall post-handler)))))))

;; bind pair trigger keys
(dolist (pair dp-pairs)
  (global-set-key (car pair) 'dp-self-insert-command)
  (define-key c-mode-base-map (car pair) 'dp-self-insert-command))

(provide 'dummyparens)