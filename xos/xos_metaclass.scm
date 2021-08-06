;;
;;   XOS Metaclass
;;
;;     This file contains three methods which extend the class ::metalclass.
;;
;;     Get/set cvars:
;;
;;       (<class> 'cvar-ref '<cvar>)
;;       (<class> 'cvar-set! '<cvar> val)
;;
;;     Get all cvar bindings as list of (name . value) pairs:
;;
;;       (<class> 'cvar-bindings)
;;
;;   These methods permit a class to be used to reference cvars.
;;

(load "./xos.scm")

(define (assert truth) 
  (if (not truth) 
      (error "assertion failed") 
      #t))

(::metaclass 'method 'cvar-ref '(<cvar>) 
	     '((eval `(access ,<cvar> (self 'cvars)) 
		     (the-environment))))

(::metaclass 'method 'cvar-set! '(<cvar> <val>) 
	     '((eval `(set! (access ,<cvar> (self 'cvars)) <val>)
		     (the-environment))))

(::metaclass 'method 'cvar-bindings '() 
	     '((let ((pairs nil)
		     (cvars (self 'cvars)))
		 (while cvars
			(set! pairs (append (environment-bindings cvars) pairs))
			(set! cvars (environment-parent cvars)))
		 (reverse pairs))))

(::metaclass 'show)

;;
;; Let's review what happens to the 'cvar-ref method.
;;
;;   1. XOS defines a signature with implicit self:
;;
;;        ([self] <cvar>)
;;
;;      "self" is bound to the receiving instance, in this case
;;      an instance of class ::metaclass.
;;
;;   2. The body uses quasiquote expansion to build the access form:
;;
;;        a. The value of <cvar> is desired, thus the comma splice
;;        b. The value of <val> is also desired
;;        c. eval evaluates the expanded form in the context of
;;           the current environment -- the generated lambda
;;           where "self" is bound to the instance of ::metaclass.
;;
;;   The methods ultimately produced:
;;
;;     'cvar-ref:
;;
;;        (lambda (self <cvar>)
;;           (eval `(access ,<cvar> (self 'cvars)) 
;;                 (the-environment)))
;;
;;     'cvar-set!:
;;
;;        (lambda (self <cvar> <val>)
;;           (eval `(set! (access ,<cvar> (self 'cvars)) <val>) 
;;                 (the-environment)))
;;

(define <foo> (class 'new '(a) '(x)))
(define <bar> (class 'new '(b) '(y) <foo>))
(define <abe> (class 'new '(c) '(z y u) <bar>))

(<foo> 'show)
(<bar> 'show)
(<abe> 'show)

;;
;; <foo>
;;

(define f1 (<foo> 'new))
(slot-set! f1 'x 100)

(print (slot-ref f1 'x))
(print (<foo> 'cvar-ref 'x))

(define x 1234)

(slot-set! f1 'x x)
(print (slot-ref f1 'x))
(print (<foo> 'cvar-ref 'x))

(<foo> 'cvar-set! 'x (* x 2))
(print (slot-ref f1 'x))
(print (<foo> 'cvar-ref 'x))

;;
;; <bar>
;;

(define b1 (<bar> 'new))
(slot-set! b1 'y 200)

(print (slot-ref b1 'y))
(print (<bar> 'cvar-ref 'y))

(let ((x 5555))
  (<foo> 'cvar-set! 'x x)
  (<bar> 'cvar-set! 'y (* x 2))
)

(print (slot-ref f1 'x))
(print (slot-ref b1 'y))

(assert (= (slot-ref f1 'x) (<foo> 'cvar-ref 'x)))
(assert (= (slot-ref b1 'y) (<bar> 'cvar-ref 'y)))

;; test inherited class var 'x
(assert (= (slot-ref b1 'x) (<bar> 'cvar-ref 'x)))

;;
;; <abe>
;;

(let ((x -20))
  (<abe> 'cvar-set! 'z x)
  (<abe> 'cvar-set! 'y (abs x))
  (<abe> 'cvar-set! 'u (* 2 x))
)

;; test inherited class var 'x
(assert (= (slot-ref b1 'x) (<abe> 'cvar-ref 'x)))


;; display the cvar bindings
(print (<foo> 'cvar-bindings))
(print (<bar> 'cvar-bindings))
(print (<abe> 'cvar-bindings))

;; [EOF]
