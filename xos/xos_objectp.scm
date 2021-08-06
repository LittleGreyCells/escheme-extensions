;;
;;   XOS Object Predicate
;;
;;     This file contains the implementation of a predicate method for XOS 
;;   objects. It is necessary to inspect the closure as object to determine 
;;   if it is an XOS object. We can do this by using two environment functions.
;;
;;      (environment-bindings (procedure-environment <object>))
;;
;;   This will return a list of bindings:
;;
;;     noise> (environment-bindings (procedure-environment ::object))
;;     ((self . { closure:0x7f26de41c8b0 }) (slots . { env:0x7f26de41caf0 }))
;;
;;   If the bindings are so structured, we conclude it is an XOS object.
;;
;;   Of course this approach can be spoofed, but the user should exercise
;;   caution.
;;

(load "./xos.scm")

(define (assert truth) 
  (if (not truth) 
      (error "assertion failed") 
      #t))

;; predicate implementation

(define object?
  (lambda (<object> )
    (and (closure? <object>)
	 (let ((x (environment-bindings (procedure-environment <object>))))
	   (and (= (length x) 2)
		(eq? (caar x) 'self)
		(eq? (caadr x) 'slots))))))
;;
;; Let's test it!
;;

(define <foo> (class 'new '(a) '(x)))

(define f1 (<foo> 'new))

(object? <foo>)
(object? f1)
(object? 1)
(object? #(1))
(object? '(1))
(object? assert)
(object? (procedure-environment assert))

;; [EOF]
