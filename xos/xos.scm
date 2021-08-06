;;
;;   XOS -- "X" Object System
;;
;;     XOS is fashioned after the XScheme object system, an integral object
;;     system included in earlier verions of XLisp and XScheme. 
;;
;;     This exclusvie escheme implementation duplicates the metaclass system, 
;;     but varies in the manner in which object attributes are accessed. 
;;
;;     There are also some minor changes in syntax and method names, but
;;     overall XOS is substantially equivalent to the XScheme object system.
;;
;;     Object 
;;       The super class of all classes. All classes derive from Object.
;;
;;     Class (Metaclass)
;;       The class whose instances are themselves classes.
;;
;;     Metaclass derives from Object
;;     Object is an instance of Metaclass
;;     Metaclass is an instance of Metaclass.
;;
;;     Key
;;        A --x> B  # A extends(is derived from) B
;;        A --i> B  # A is an instance of B
;;
;;     aClass --x> Object
;;     aClass --x> anotherClass
;;     anInstance --i> aClass
;;     aClass --i> Metaclass
;;     Metaclass --x> Object
;;     Metaclass --i> Metaclass
;;
;;                  +---+
;;                  |   |
;;                  |   i
;;                  |   V
;;         +---i> Metaclass <i---+
;;         |          |          ^
;;         |          |          |
;;         |          |          |
;;       Object <x----+------- aClass
;;         ^                     ^
;;         i                     i
;;         |                     |
;;         |                     |
;;     anInstance            anInstance
;;
;;     Why all the bother? By objectifying the object system itself, it will
;;     become extensible under derivation. In other words one can introduce
;;     "new" versions of Object and Metaclass to behave in new ways.
;;
;;     A class/object as closure implemenation.
;;
;;  Requirements
;;
;;     XOS requires macros and quasiquote.
;;     XOS requires escheme environment support functions.
;;
;;  Foundational Objects
;;
;;    ::object
;;    ::metaclass (aka class)
;;

(define g:debug #t)

(define (g:make-method <selector> <func>) (cons <selector> <func>))
(define (g:get-selector <method>) (car <method>))
(define (g:get-function <method>) (cdr <method>))

(define g:make-method cons)
(define g:get-selector car)
(define g:get-function cdr)

(define (g:get-code <closure>) (if (closure? <closure>) (%closure-code <closure>)))
(define (g:get-params <closure>) (if (closure? <closure>) (%closure-vars <closure>)))

(define (g:displayln <label> <contents>)
  (display <label>) (print <contents>))

(define (g:object-show <object>)
  (let ((<class> (::class (<object> 'slots))))
    (g:displayln "object = " <object>)
    (g:displayln "  class = " <class>)
    (let ((ivars (<class> 'ivars)))
      (while ivars
	 (let ((ivar (car ivars)))
	   (display "  ")
	   (display ivar)
	   (display " = ")
	   (print (slot-ref <object> ivar))
	   (set! ivars (cdr ivars)))))
    ))

(define (g:class-show <object>)
  (g:displayln "class = " <object>)
  (g:displayln "  class = " (::class (<object> 'slots)))
  (g:displayln "  super = " (::super (<object> 'slots)))
  (g:displayln "  ivars = " (<object> 'ivars))
  (g:displayln "  cvars = " (<object> 'cvars))
  (for-each (lambda (x) (g:displayln "  method = " x)) (<object> 'methods)))

(define (g:add-method <slots> <selector> <method>)
  (let ((add-method-aux
	 (lambda (<selector> <function> methods)
	   (let ((pair (assoc <selector> methods)))
	     (if pair
		 (begin (set-cdr! pair <function>) methods)
		 (cons (g:make-method <selector> <function>) methods))))))
    (::set-methods <slots> (add-method-aux <selector> <method> (::methods <slots>))))
  <selector>)

(define (g:rem-method <slots> <selector>)
  (letrec ((rem-method-aux 
	    (lambda (<selector> methods)
	      (if (null? methods)
		  nil
		  (if (eq? <selector> (g:get-selector (car methods)))
		      (cdr methods)
		      (cons (car methods) (rem-method-aux <selector> (cdr methods))))))))
    (::set-methods <slots> (rem-method-aux <selector> (::methods <slots>)))))

(define g:class-add-method
  (lambda (self <selector> <params> <body>)
    (g:add-method (self 'slots) 
		  <selector> 
		  (eval `(let ((%methodclass ,self)) 
			   (lambda (self ,@<params>) ,@<body>))))))

(define g:class-rem-method
  (lambda (self <selector>) 
    (g:rem-method (self 'slots) <selector>)))

;;
;; Accessors
;;

;;
;;   (slot-ref <obj> '<var>)
;;   (slot-set! <obj> '<var> <val>)
;;

(define slot-ref
  (lambda (<obj> <var>)
    (eval `(access ,<var> (<obj> 'slots)) 
	  (the-environment))))

(define slot-set!
  (lambda (<obj> <var> <val>)
    (eval `(set! (access ,<var> (<obj> 'slots)) <val>) 
	  (the-environment))))
 
;;
;; 'new and 'init
;;

(define (g:object-init self . args) 
  self)

(define (all-symbols? x)
  (if (null? x)
      #t
      (if (not (symbol? (car x)))
	  #f
	  (all-symbols? (cdr x)))))

(define (make-assoc x)
  (let (as)
    (while x
       (set! as (cons (list (car x)) as))
       (set! x (cdr x)))
    as))

(define (g:make-env <bindings> <benv>)
  (%make-environment
   <bindings>
   (if (null? <benv>)
       (the-global-environment)
       <benv>)))

(define (g:class-init self <ivars> . <rest>)
  (let ((slots (self 'slots))
	<cvars>
	<super>)
    ;; argument parsing
    (if (not (null? <rest>))
	(begin
	  (set! <cvars> (car <rest>))
	  (set! <rest> (cdr <rest>))))
    (if (not (null? <rest>))
	(begin
	  (set! <super> (car <rest>))
	  (set! <rest> (cdr <rest>))))
    (if (null? <super>)
	(set! <super> ::object))
    (if (not (null? <rest>))
	(error "extra class init arguments" <rest>))
    (if (not (all-symbols? <ivars>))
	(error "illegal ivar list" <ivars>))
    (if (not (all-symbols? <cvars>))
	(error "illegal cvar list" <cvars>))

    ;; assignment
    (::set-super slots <super>)
    (::set-ivars slots (append (<super> 'ivars) <ivars>))
    (::set-cvars slots (g:make-env <cvars> (<super> 'cvars)))

    self))
 
;; prepend '%%class when instantiating any object

(define (g:object-new <class> . args)
  (let ((self nil)
	(slots (g:make-env (cons '%%class (<class> 'ivars)) (<class> 'cvars)))
	)
    (let ((<this> 
	   (lambda args
	     (let ((<selector> (car args)))
	       (if (eq? <selector> 'slots)
		   slots
		   (g:dispatch <selector> <class> self (cdr args)))))))
      (set! self <this>)
      (::set-class slots <class>)
      (g:dispatch 'init <class> self args)
      <this>
      )))

;;
;; find and dispatch
;;

(define (g:find <selector> <class>)
  (if (null? <class>)
      (error "no method found" <selector>)
      (let ((<method> (assoc <selector> (::methods (<class> 'slots)))))
	(if <method>
	    (g:get-function <method>)
	    (g:find <selector> (::super (<class> 'slots)))
	    ))))

(define (g:dispatch <selector> <class> <self> <args>)
  (let ((<func> (g:find <selector> <class>))
	(<args> (cons <self> <args>)))
    (apply <func> <args>)))


;;==================================================================================
;;
;; Bootstrapping the Object System
;;
;;==================================================================================

;; slots

(define (::class   slots) (access %%class slots))
(define (::super   slots) (access super slots))
(define (::ivars   slots) (access ivars slots))
(define (::methods slots) (access methods slots))
(define (::cvars   slots) (access cvars slots))

(define (::set-class   slots x) (set! (access %%class slots) x))
(define (::set-super   slots x) (set! (access super slots) x))
(define (::set-ivars   slots x) (set! (access ivars slots) x))
(define (::set-methods slots x) (set! (access methods slots) x))
(define (::set-cvars   slots x) (set! (access cvars slots) x))

(define (make-assoc x)
  (if (null? x)
      nil
      (cons (list (car x)) (make-assoc (cdr x)))))

(define g:class-ivars '(super ivars cvars methods))

;; prepend '%%class when instantiating any object

(define (g:raw-object ivars benv)
  (let ((self nil)
	(slots (g:make-env (cons '%%class ivars) benv)))
    (let ((<this>
	   (lambda args
	     (let ((<selector> (car args)))
	       (if (eq? <selector> 'slots) 
		   slots
		   (g:dispatch <selector> (::class slots) self (cdr args)))))))
      (set! self <this>)
      <this>
      )))

;;
;; Object
;;

(define ::object (g:raw-object g:class-ivars nil))

(let ((slots (::object 'slots)))
  (g:add-method slots 'init g:object-init)
  (g:add-method slots 'show g:object-show)
  )

;;
;; Metaclass
;;

(define ::metaclass (g:raw-object g:class-ivars nil))

(let ((slots (::metaclass 'slots)))

  (::set-super  slots ::object)
  (::set-ivars  slots g:class-ivars)

  (g:add-method slots 'class (lambda (self) (::class (self 'slots))))
  (g:add-method slots 'super (lambda (self) (::super (self 'slots))))
  (g:add-method slots 'ivars (lambda (self) (::ivars (self 'slots))))
  (g:add-method slots 'methods (lambda (self) (::methods (self 'slots))))
  (g:add-method slots 'cvars (lambda (self) (::cvars (self 'slots))))
  (g:add-method slots 'init g:class-init)
  (g:add-method slots 'show g:class-show)
  (g:add-method slots 'new g:object-new)
  (g:add-method slots 'method g:class-add-method)
  (g:add-method slots 'remove g:class-rem-method)
  )

;; final fixups
(::set-class (::object 'slots) ::metaclass)
(::set-class (::metaclass 'slots) ::metaclass)

;; conveniences

(define class ::metaclass)

(define (g:class <object>)
  (::class (<object> 'slots)))

(define (g:super <class>)
  (::super (<class> 'slots)))

;; predicate

(define object?
  (lambda (<object> )
    (and (closure? <object>)
	 (let ((x (environment-bindings (procedure-environment <object>))))
	   (and (= (length x) 2)
		(eq? (caar x) 'self)
		(eq? (caadr x) 'slots))))))

;;
;; (send-super '<selector> [<args>...])
;;
;;   free variables:
;;     %methodclass -- used from parent env
;;     self -- used from current env
;;

(macro send-super
  (lambda (form)
    (let ((<selector> (cadr form))
	  (<args> (cddr form)))
      `((g:find ,<selector> (g:super %methodclass)) self ,@<args>))))

