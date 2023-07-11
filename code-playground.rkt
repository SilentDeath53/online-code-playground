#lang web-server/insta
(require web-server/servlet
         web-server/servlet-env)

(define (render-page)
  (response/xexpr
   `(html
     (head (title "Code Playground"))
     (body
      (h1 "Code Playground")
      (form ((action "/run") (method "post"))
            (textarea ((name "code") (rows "10") (cols "50")) "Enter your code here...")
            (br)
            (input ((type "submit") (value "Run")))))))


(define (execute-code code)
  ;; Execute the code and return the result
  (with-output-to-string
    (lambda ()
      (with-input-from-string code
        (lambda ()
          (eval (read))))))


(define (handle-request request)
  (cond
    [(string=? (request-method request) "GET")
     (render-page)]
    [(string=? (request-method request) "POST")
     (let* ((code (hash-ref (request-post-params request) 'code ""))
            (result (execute-code code)))
       (response/xexpr
        `(html
          (head (title "Code Playground - Result"))
          (body
           (h1 "Code Playground - Result")
           (pre ,(format "Result: ~a" result))
           (a ((href "/")) "Back to Code Playground")))))]))


(serve/servlet handle-request #:port 8080)
