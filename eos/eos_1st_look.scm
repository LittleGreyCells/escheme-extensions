;;
;; Demonstrate Basic EOS Functionality
;;
;;   1. class creation
;;   2. class derivation
;;   3. instance instantiation
;;   4. generic function lookup via internal function gf-find
;;       (this is normally not used)
;;   5. use of next-function
;;   6. non-instance functions
;;
;; Directions
;;   Copy and paste each of these s-expression at the noise> prompt.
;;
;;   Note: This file will not execute completely via load.
;;         When an expected error occurs, the prompt is asserted.
;;   

;;
;; Loading EOS
;;
;;   Place all the EOS implementation files in the current working directory:
;;
;;     ./eos.scm
;;     ./eos_classes.scm
;;     ./eos_gfuncs.scm
;;     ./eos_dispatch.scm
;;
;;   Load the main file:
;;
;;     (load "./eos.scm")
;;
;;   Go.
;;

(load "./eos.scm")

;; there should be no generic function defined at this point
(generic-functions-show)

;; define class foo derived from <object> with single slot
;;   since no type is associated with "x", it defaults to type <object>
(define-class foo <object> (x))
(class-show foo)

;; define class foo2 like foo, but explicitely type its slot var
(define-class foo2 <object> ((x <object>)))
(class-show foo2)

;; define class bar deriving from foo; introduce new slot of type <object>
(define-class bar foo (y))
(class-show bar)

;; at this point a number of automatic generic functions have been defined: 
;; setters and getters.
;;   o set-x, get-x
;;   o set-y, get-y
;;
;; for each generic function the following is displayed:
;;   name: <name>
;;     <signature>
;;     <dispatcher>
;;     {<instance>}*
(generic-functions-show)

;; create instances of class foo and class bar with initial values
(define foo1 (make foo (x 10)))
(define bar1 (make bar (x 10) (y 20)))

(object-bindings foo1)
(object-bindings bar1)

;; define class bob deriving from bar; add members coffee, milk, inherit y, x
(define-class bob bar (coffee milk))
(class-show bob)

;; define class bill deriving from bob; no new members are added
(define-class bill bob ())
(class-show bill)

;; there should be new getters/setters for coffee and milk
(generic-functions-show)

;;
;; explicitly define some generic functions and their implemenations
(define-generic-function mary ((a foo)))
(define-generic-function sam (x y z))

(generic-functions-show)

;; Define an instance of the generic function mary
;;   it takes a single argument of type <object>
;;   its implementation simple returns 0
(define-function mary ((a <object>)) 0)   ;; should be ok, based on num 
                                          ;; required no types
(generic-functions-show)

;; Discussion: 
;;   Why wasn't the above implemenation an error?
;;   Shouldn't type foo place a type constraint on any subsequent implementation?
;;
;;   
;;   

(define-function mary ((a foo)) 1)        ;; ok, exact
(generic-functions-show)

(define-function mary ((a bar)) 2)        ;; ok, bar -> foo
(generic-functions-show)

(define-function sam (x y z) (+ x y z))
(generic-functions-show)

;; define a function which doesn't already have a generic function created.
;; auto create one
(define-function gil (x) x)
(generic-functions-show)

;; we will use these functions later in this section

;; define class larry with members
(define-class larry <object> (x kate chris ben))
(class-show larry)

(generic-functions-show)

;; define class <integer> deriving from <object>
;;   it has a member x of any type, but has a type predicate integer? to applied
;;   when instances are created
(define-class <integer> <object> ((x <object> integer?)))
(class-show <integer>)

;; let's make some instances
(define f1 (make foo))
(define f3 (make <integer> (x 0)))

(get-x f1)
(set-x f1 10)
(get-x f1)

(get-x f3)

(object-class f1)

;; show slots and bound values
(object-bindings f1)
(object-bindings f3)

(set-x f3 20)
(get-x f3)

;; show slots and bound values
(object-bindings f3)

(set-x f3 'a)   ;; error

(next-function) ;; error -- no next function?

;; call the generic function

(mary f1)  ;; return 1
(mary 1)   ;; return 0

(next-function) ;; error -- no next function

(define b1 (make bar))

(mary b1)        ;; return 2

(next-function)  ;; next in order is instance: ((a foo)), imp: (1); return 1
(next-function)  ;; next in order is instance: ((a <object>)), imp: (0); return 0
(next-function)  ;; no next function, so an error

;; define several normal functions (closures)
(define fn1 (function (a) a))
(define fn2 (function ((f1 foo)) (get-x f1)))
(define fn3 (function ((f3 bill)) (get-x f3)))

(fn1 1)   ;; return 1
(fn2 f1)  ;; f1 is a foo; return f1's x

(define w1 (make bill (x 100)))

(fn3 w1)  ;; return 100

(generic-functions-show)

(add-function mary fn3)

(mary w1) ;; mary now returns 100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Mixed-mode Arithmetic
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; define an <integer> class with value-guard "integer?"
(define-class <integer> <object> ((value <object> integer?)))

;; define a <real> class
(define-class <real> <object> ((value <object> real?)))

;; define a generic-function pattern
(define-generic-function add (x y))

;; provide implementations for generic function "add"
(define-function add ((x <integer>) (y <integer>)) 
  (make <integer> (value (+ (get-value x) (get-value y) ))))

(define-function add ((x <real>) (y <real>))    
  (make <real> (value (+ (get-value x) (get-value y) ))))


;; construct objects using special function “make”
(define x1 (make <integer> (value 10)))
(define x2 (make <integer> (value 20)))

(define y1 (make <real> (value 10.0)))
(define y2 (make <real> (value 20.0)))
 
(define x3 (add x1 x2))
(define y3 (add y1 y2))

(define z3 (add x1 y2))    ;; an error--no such implemenation 
                           ;;   (+ <integer> <real>)
(define z4 (add y2 x1))    ;; an error--no such implemenation 
                           ;;   (+ <real> <integer>)


;; let's add some mixed mode support
(define-function add ((x <integer>) (y <real>)) 
  (make <real> (value (+ (get-value x) (get-value y) ))))

(define-function add ((x <real>) (y <integer>)) 
  (make <real> (value (+ (get-value x) (get-value y) ))))

(define z3 (add x1 y2))    ;; no longer an error
(define z4 (add y2 x1))    ;; no longer an error

(print (list (get-value x1)
	     (get-value y2)
	     (get-value z3)))

(print (list (get-value y2)
	     (get-value x1)
	     (get-value z4)))

;;
;; Is EOS needed? 
;;
;; Native scheme provides adequate implemenation primitives. Lists and 
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
;; (define-function push ((stack <stack>) item) ...)
;; (define-function pop ((stack <stack>)) ...)
;; (define-function top ((stack <stack>)) ...)
;; (define-function set-top! ((stack <stack>) item) ...)
;; ...
;; 
;; (class <stack-of-integer> <object> ...)
;; (define-function push ((stack <stack-of-integer>) (item <integer>)) ...)
;; (define-function pop ((stack <stack-of-integer>)) ...)
;; (define-function top ((stack <stack-of-integer>)) ...)
;; (define-function set-top! ((stack <stack-of-integer>) (item <integer>)) ...)
;; ...
;; 
;; (class <card> <object>...)
;; (define-function show ((card <card>)) ...)
;; (define-function red? ((card <card>)) ...)
;; (define-function black? ((card <card>)) ...)
;; (define-function up? ((card <card>)) ...)
;; (define-function down? ((card <card>>)) ...)
;; ...
;; 
;; (class <deck> <object>...)
;; (define-function new ((deck <deck>)) ...)
;; (define-function add ((deck <deck>) (card <card>)) ...)
;; (define-function copy ((to-deck <deck>) (from-deck <deck>)) ...)
;; (define-function move ((to-deck <deck>) (from-deck <deck>)) ...)
;; (define-function show ((deck <deck>)) ...)
;; (define-function shuffle ((deck <deck>)) ...)
;; (define-function peek-top ((deck <deck>)) ...)
;; (define-function pop-top ((deck <deck>)) ...)
;; ...
;; 

;; [EOF]

