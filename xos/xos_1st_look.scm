;;
;;   XOS 1st Look
;;
;;     This file contains a series of running examples demonstrating
;;   the use of essential XOS features.
;;
;;     Code is presented as chunks which can be copied and pasted at
;;   the escheme prompt.
;;

;;
;; ============================
;; Pre) Prepare to run XOS code
;;        start escheme
;;        change directory to where XOS is installed
;;        load XOS
;;        load a simple assert function
;;

(load "./xos.scm")
(define (assert truth) (if (not truth) (error "assertion failed") #t))

;;
;; =======================================================================
;; Ex1) Define a class and assign it to the symbol <foo> in the global env
;;
;;      1. <foo> has a single instance variable 'a
;;      2. <foo> has a single class (shared) variable 'x
;;      3. <foo> inherits from ::object, since no superclass is specified
;;

(define <foo> (class 'new '(a) '(x)))
(<foo> 'show)

;; create some instances of <foo> and examine their internals
(define f0 (<foo> 'new))
(f0 'show)

(define f1 (<foo> 'new))
(f1 'show)

(slot-set! f0 'a 10)
(slot-set! f1 'a 20)

(f0 'show)
(f1 'show)

;; verify that respective instances vars are different
(assert (not (= (slot-ref f0 'a) (slot-ref f1 'a))))

;; set the shared variable
(slot-set! f0 'x 15)

;; show doesn't reveal the shared variables; use slot-ref
(slot-ref f0 'x)
(slot-ref f1 'x)

;; verify that shared var value is the same
(assert (= (slot-ref f0 'x) (slot-ref f1 'x)))

;;
;; ======================================================================
;; Ex2) Define a class <bar> which inherits state and behavior from <foo>
;;
;;      1. <bar> will have two instance variables 'a and 'b
;;      2. <bar> introduces a new shared variable 'y
;;

(define <foo> (class 'new '(a) '(x)))
(define <bar> (class 'new '(b) '(y) <foo>))

(<bar> 'show)

;; create an instance of <bar>
(define b0 (<bar> 'new))
(b0 'show)

;; assign values to the instance and class variables of b0 (a <bar>)
(slot-set! b0 'b 100)
(slot-set! b0 'y 200)

(b0 'show)

;; b0's 'a is unassigned
(assert (eq? (slot-ref b0 'a) nil))

;; examine the shared variable 'x -- it's the same for f0 and b0
(define f0 (<foo> 'new))

(slot-set! f0 'x 10)
(slot-ref f0 'x)
(slot-ref b0 'x)

;; verify that it is the same for each
(assert (= (slot-ref f0 'x) (slot-ref b0 'x)))

;; examine the shared variable 'y
(slot-ref b0 'y)

;; it's undefind for f0; <bar> inherits from <foo>, not vice versa
(slot-ref f0 'y)

;; a getter and setter method to <foo>
(<foo> 'method 'get-a '() '((slot-ref self 'a)))
(<foo> 'method 'set-a '(val) '((slot-set! self 'a val)))
(<foo> 'show)

(f0 'set-a 10)
(f0 'get-a)

;; verify the getter and slot-ref in this instance return the same value
(assert (= (f0 'get-a) (slot-ref f0 'a)))

;; even though we added method 'get-a to <foo>, it also works for instances of <bar>
(slot-set! b0 'a 1000)
(assert (= (b0 'get-a) (slot-ref b0 'a)))

(f0 'show)
(b0 'show)

;;
;; ================================================================================
;; Ex3) Add an 'init method to <foo> which gets called after construction with 'new
;;
;;      1. 'init must also use the slot accessor 'a which gets auto-generated
;;      2. by convention 'init returns self
;;

(define <foo> (class 'new '(a) '(x)))
(<foo> 'method 'init '(value) '((slot-set! self 'a value) self))
(<foo> 'method 'get-a '() '((slot-ref self 'a)))
(<foo> 'method 'set-a '(val) '((slot-set! self 'a val)))
(<foo> 'show)

;; object construction now requires the additional argument used by 'init
(define f1 (<foo> 'new 100))

;; this will complain of a missing 'init value
(define f2 (<foo> 'new))

;; verify that f1's 'a was initialized
(assert (= (f1 'get-a) 100))


;;
;; ==================================
;; Ex4) Derive two additional classes
;;
;;        <abe> derived from <bar>
;;        <bob> derived from <abe>
;;

(define <foo> (class 'new '(a) '(x)))
(<foo> 'method 'init '(value) '((slot-set! self 'a value) self))

(define <bar> (class 'new '(b) '(y) <foo>))
(define <abe> (class 'new '(e f) '() <bar>))
(<abe> 'show)

;; <abe> has a total of 4 instance variables -- 'a, 'b, 'e, 'f

(define <bob> (class 'new '(x) '(y) <abe>))
(<bob> 'show)

;; <bob> has a total of 5 instance variables -- 'a, 'b, 'e, 'f, 'x

;; but wait ... 
;;   isn't 'x already defined as shared by <foo>? Yes. <bob>'s masks <foo>'s.
;;   isn't 'y already defined as shared by <bar>? Yes. <bob>'s masks <bar>'s.
;;
;; the 'init for 'a is still operational.

(define f1 (<foo> 'new 1))
(define b1 (<bar> 'new 2))
(define a1 (<abe> 'new 3))
(define bob1 (<bob> 'new 4))

(f1 'show)
(b1 'show)
(a1 'show)
(bob1 'show)

(assert (= (slot-ref f1 'a) 1))
(assert (= (slot-ref b1 'a) 2))
(assert (= (slot-ref a1 'a) 3))
(assert (= (slot-ref bob1 'a) 4))

(assert (eq? (slot-ref a1 'f) nil))

;; it can get confusing...

;; 
;; ===========================
;; Ex5) Slots are environments
;;
;;      1. examine object's instance variables
;;      2. examine class vars
;;         a. level 0
;;         b. all levels
;;
(define <foo> (class 'new '(a) '(x)))
(define <bar> (class 'new '(b) '(y) <foo>))
(define <abe> (class 'new '(e f) '() <bar>))
(define <bob> (class 'new '(x) '(y) <abe>))

(<foo> 'method 'init '(value) '((slot-set! self 'a value) self))

(define f1 (<foo> 'new 1))
(define b1 (<bar> 'new 2))
(define a1 (<abe> 'new 3))
(define bob1 (<bob> 'new 4))

(slot-set! f1 'x 101)
(slot-set! b1 'y 201)
(slot-set! bob1 'y 401)

;; instance vars
(environment-bindings (f1 'slots))
(environment-bindings (b1 'slots))
(environment-bindings (a1 'slots))
(environment-bindings (bob1 'slots))

;; class vars (at the immediate level)
(environment-bindings (<foo> 'cvars))
(environment-bindings (<bar> 'cvars))
(environment-bindings (<abe> 'cvars))
(environment-bindings (<bob> 'cvars))

;; show all levels

(define (show-cvars <class>)
  (let ((env (<class> 'cvars))
	(level 0))
    (while (not (global-env? env))
       (display level)
       (display ": ")
       (print (environment-bindings env))
       (set! env (environment-parent env))
       (set! level (1+ level))
       )))

(show-cvars <foo>)
(show-cvars <bar>)
(show-cvars <abe>)
(show-cvars <bob>)

;;
;; ===========================
;; Ex6) Demonstrate send-super
;;
;;      1. classes:
;;          <foo>
;;          <bar> -i> <foo>
;;          <abe> -i> <bar>
;;          <bob> -i> <abe>
;;      2. define an 'init for each class
;;      3. each derived class invokes the 'init in the parent
;;
;;      send-super finds the correct 'init method 
;;      in the current method's class's parent (got it?)
;;

(define (out x) (display x) (newline))

(<foo> 'method 'init '(x) '((out "<foo>:init") 
			    (slot-set! self 'a x) self))

;; call <foo>'s 'init
(<bar> 'method 'init '(x) '((send-super 'init x) 
			    (out "<bar>:init") self))

;; call <bar>'s 'init
(<abe> 'method 'init '(x) '((send-super 'init x) 
			    (out "<abe>:init") self))

;; call <abe>'s 'init
(<bob> 'method 'init '(x) '((send-super 'init x) 
			    (out "<bob>:init") self))

(define foo2 (<foo> 'new 1000))
(define bar2 (<bar> 'new 2000))
(define abe2 (<abe> 'new 3000))
(define bob2 (<bob> 'new 4000))

(assert (= (slot-ref foo2 'a) 1000))
(assert (= (slot-ref bar2 'a) 2000))
(assert (= (slot-ref abe2 'a) 3000))
(assert (= (slot-ref bob2 'a) 4000))

(foo2 'show)
(bar2 'show)
(abe2 'show)
(bob2 'show)

(<foo> 'show)
(<bar> 'show)
(<abe> 'show)
(<bob> 'show)

;; [EOF]
