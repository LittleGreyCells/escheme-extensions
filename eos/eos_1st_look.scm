;;
;; Demonstrate Basic EOS Functionality
;;
;;   1. class creation
;;   2. class derivation
;;   3. instance instantiation
;;   4. generic function lookup via internal function gf-find
;;       (this is normally not used)
;;   5. use of next-method
;;   6. non-instance functions
;;
;; Directions
;;   Copy and paste each of these s-expression at the noise> prompt.
;;
;;   Note: This file will not execute completely via load.
;;         When an expected error occurs, the prompt is asserted.
;;   

(load "../escheme-extensions/eos/eos.scm")

;; there should be no generic function defined at this point
(generic-functions-show)

;; define class <foo> derived from <object> with single slot
;;   since no type is associated with "x", it defaults to type <object>
(define-class <foo> <object> (x))
(class-show <foo>)
(define-method init ((this <foo>) n) ((setter x) this n))
(define foo1 (make <foo> 10))
(object-bindings foo1)

;; define class <foo2> like foo, but explicitely type its slot var
(define-class <foo2> <object> ((x <object>)))
(class-show <foo2>)

;; define class <bar> deriving from <foo>; introduce new slot of type <object>
(define-class <bar> <foo> (y))
(class-show <bar>)
(define-method init ((this <bar>) n m)
  ((setter x) this n)
  ((setter y) this m))
(define bar1 (make <bar> 10 20))
(object-bindings bar1)

;; for each generic function the following is displayed:
;;   name: <name>
;;     <num-args>
;;     <signature>
;;     {<instance>}*
(generic-functions-show)

;; define class <bob> deriving from bar; add members coffee, milk, inherit y, x
(define-class <bob> <bar> (coffee milk))
(class-show <bob>)

;; define class <bill> deriving from <bob>; no new slots are added
(define-class <bill> <bob> ())
(class-show <bill>)

;; there should be new getters/setters for coffee and milk
(generic-functions-show)

;; Define an instance of the generic function mary
;;   it takes a single argument of type <object>
;;   its implementation simple returns 0
(define-method mary ((a <object>)) 0)   ;; should be ok, based on num 
                                        ;; required no types
(generic-functions-show)

;;   

(define-method mary ((a <foo>)) 1)        ;; ok, exact
(generic-functions-show)

(define-method mary ((a <bar>)) 2)        ;; ok, bar -> foo
(generic-functions-show)

(define-method sam (x y z) (+ x y z))
(generic-functions-show)

(define-method gil (x) x)
(generic-functions-show)

;; we will use these functions later in this section

;; define class larry with members
(define-class <larry> <object> (x kate chris ben))
(class-show <larry>)

(generic-functions-show)

;; define class <integer> deriving from <object>
;;   it has a member x of any type, but has a type predicate integer? to be applied
;;   when instances are created
(define-class <integer> <object> ((x <object> integer?)))
(class-show <integer>)
(define-method init ((this <integer>) n) ((setter x) this n))

;; let's make some instances
(define f1 (make <foo>))
(define f3 (make <integer> 0))

(object-class f1)
(object-class f3)

;; show slots and bound values
(object-bindings f1)
(object-bindings f3)

(slot-set! f3 x 20)
(slot-ref f3 x)

;; show slots and bound values
(object-bindings f3)

(next-method) ;; error -- no next function?

;; call the generic function

(mary f1)  ;; return 1
(mary 1)   ;; return 0

(next-method) ;; error -- no next function

(define b1 (make <bar>))

(mary b1)        ;; return 2

(next-method)  ;; next in order is instance: ((a foo)), imp: (1); return 1
(next-method)  ;; next in order is instance: ((a <object>)), imp: (0); return 0
(next-method)  ;; no next function, so an error

(define-method fran ((a <object>) n) (* n 1))
(define-method fran ((a <foo>) n) (* n 2))
(define-method fran ((a <bar>) n) (* n 3))

(generic-functions-show)

(fran b1 10)

(next-method b1 100)  ;; next in order is instance: ((a foo) n), imp: (* n 2); return 200
(next-method b1 100)  ;; next in order is instance: ((a <object>) n), imp: (n); return 100
(next-method b1 100)  ;; no next function, so an error

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Mixed-mode Arithmetic
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; define an <integer> class with value-guard "integer?"
(define-class <integer> <object> ((value <object> integer?)))
(define-method init ((this <integer>) n) ((setter value) this n))

;; define a <real> class
(define-class <real> <object> ((value <object> real?)))
(define-method init ((this <real>) n) ((setter value) this n))

(generic-functions-show)

;; provide implementations for generic function "add"
(define-method add ((x <integer>) (y <integer>)) 
  (make <integer> (+ (value x) (value y) )))

(define-method add ((x <real>) (y <real>))    
  (make <real> (+ (value x) (value y) )))


;; construct some number objects
(define x1 (make <integer> 10))
(define x2 (make <integer> 20))

(define y1 (make <real> 10.0))
(define y2 (make <real> 20.0))
 
(define x3 (add x1 x2))
(define y3 (add y1 y2))

(define z3 (add x1 y2))    ;; an error--no such implemenation 
                           ;;   (+ <integer> <real>)
(define z4 (add y2 x1))    ;; an error--no such implemenation 
                           ;;   (+ <real> <integer>)


;; let's add some mixed mode support
(define-method add ((x <integer>) (y <real>)) 
  (make <real> (+ (value x) (value y) )))

(define-method add ((x <real>) (y <integer>)) 
  (make <real> (+ (value x) (value y) )))

(define z3 (add x1 y2))    ;; no longer an error
(define z4 (add y2 x1))    ;; no longer an error

(print (list (value x1)
	     (value y2)
	     (value z3)))

(print (list (value y2)
	     (value x1)
	     (value z4)))

;;
;; Is EOS needed? 
;;
;; Native scheme provides adequate implemenation primitives -- lists and 
;; vectors can be used for data structuring. Functions can be used for 
;; interface operations. Naming can make clear which operations should be 
;; grouped together. See the EOS implementation. Environments and higher 
;; order functions can be used as well, as demonstrated throughout SIPC.
;; 
;; Even still, EOS greatly simplifies data abstraction through classes 
;; and generic functions. Function argument typing binds the operation
;; to the type (or types) it operates on. Groups of such related operations
;; can be readily identified as an interface. EOS does the hard work of
;; such organization.
;; 
;; (class <stack> <object> ...)
;; (define-method push ((stack <stack>) item) ...)
;; (define-method pop ((stack <stack>)) ...)
;; (define-method top ((stack <stack>)) ...)
;; (define-method set-top! ((stack <stack>) item) ...)
;; ...
;; 
;; (class <stack-of-integer> <object> ...)
;; (define-method push ((stack <stack-of-integer>) (item <integer>)) ...)
;; (define-method pop ((stack <stack-of-integer>)) ...)
;; (define-method top ((stack <stack-of-integer>)) ...)
;; (define-method set-top! ((stack <stack-of-integer>) (item <integer>)) ...)
;; ...
;; 
;; (class <card> <object> ...)
;; (define-method show ((card <card>)) ...)
;; (define-method red? ((card <card>)) ...)
;; (define-method black? ((card <card>)) ...)
;; (define-method up? ((card <card>)) ...)
;; (define-method down? ((card <card>>)) ...)
;; ...
;; 
;; (class <deck> <object> ...)
;; (define-method new ((deck <deck>)) ...)
;; (define-method add ((deck <deck>) (card <card>)) ...)
;; (define-method copy ((to-deck <deck>) (from-deck <deck>)) ...)
;; (define-method move ((to-deck <deck>) (from-deck <deck>)) ...)
;; (define-method show ((deck <deck>)) ...)
;; (define-method shuffle ((deck <deck>)) ...)
;; (define-method peek-top ((deck <deck>)) ...)
;; (define-method pop-top ((deck <deck>)) ...)
;; ...
;; 

;; [EOF]

