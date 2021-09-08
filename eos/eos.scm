;;
;; Escheme Object System (EOS)
;;
;;    A minimial object system for extensible scheme
;;
;; Grammar
;;
;;    (define-class <name> <basetype> <slots>)
;;
;;       <slots> := ( <slot> ... )
;;       <slot> := ( <name> <type> [<value-guard>]) | <name>
;;       <name> := scheme symbol
;;       <type> := eos class type
;;
;;    (define-generic-function <name> <formals>)
;;    (define-function <name> <formals> <body>)
;;    (function <formals> <body>)
;;
;;       <formals> := (<formal> ...)
;;       <formal> := (<name> <type>) | <name>
;;       <body> := scheme symbolic expressions
;;
;;    (make <type> <init-list>)
;;
;;       <init-list> := (<slot-name> <value>) (<slot-name> <value>) ...
;;        returns instance of <type>
;;
;;    (slot-ref <slot-name> <instance>)
;;    (slot-set! <slot-name> <instance> <value>)
;;
;; Description
;;
;;    macro define-class 
;;      creates the class <name>
;;
;;    macro define-generic-function 
;;      creates the generic function <name>
;;
;;    macro define-function 
;;      creates an implementation of generic function <name>
;;
;;    macro function
;;      creates and returns a typed function; this differs
;;      form a normal scheme closure in that is tests the
;;      types of the arguments it is invoked with.
;;
;;    macro make
;;      creates and returns an <instance> of <type>
;;      slots are assigned with values provided.
;;
;;    macro slot-ref
;;      references and returns a slot value of <object>
;;
;;    macro slot-set!
;;        assigns value to a slot of <object>
;;        does not check for assignment compatibility
;;

;;=========================================================
;; Classes and Objects
;;
;;    Class representation
;;    Class construction
;;    Object representation
;;    Object construction
;;    Class parsing
;;    Class definition
;;
;; syntax: (make-class cname super slots) --> class
;; syntax: (class? arg) --> boolean
;; syntax: (class-get-name class) --> symbol
;; syntax: (class-get-super class) --> class
;; syntax: (class-get-slots class) --> vector
;; syntax: (class-get-vars class) --> list
;; syntax: (class-set-vars class slots)
;; syntax: (class-generate-vars class) --> list
;; syntax: (slot-show slot)
;; syntax: (class-show class)
;; syntax: (class-image class) -> string
;;
;; syntax: (make-object class) --> object
;; syntax: (object? arg) --> boolean
;; syntax: (object-class object) --> class
;; syntax: (object-env object) --> env
;; syntax: (object-bindings object) --> bindings {association list}
;; syntax: (object-image object) --> string
;;
;; syntax: (subclass? class1 class2) --> boolean
;; syntax: (deriv-distance class1 class2) --> fixnum
;; syntax: (instance? object class) --> boolean
;;
;; syntax: (parse-slot slot) -> parsed-slot-representation
;; syntax: (make-access-name accessor:symbol slotname:symbol) --> symbol
;; syntax: (getter slot-name) --> closure
;; syntax: (setter slot-name) --> closure
;; syntax: (generate-getter class slot)
;; syntax: (setter-error value)
;; syntax: (generate-setter clas slot guard)
;; syntax: (parse-super class) --> class
;; syntax: (fn:define-class class super slots) --> class
;;

(define class-tag 'class)

(define make-class
  (lambda (cname super slots)
    (let ((class-attr (vector cname super slots nil)))
      (cons class-tag class-attr))))

(define class? 
  (lambda (x) 
    (and (pair? x) (eq? (car x) class-tag))))

(define class-get-name  (lambda (x) (and (class? x) (vector-ref (cdr x) 0))))
(define class-get-super (lambda (x) (and (class? x) (vector-ref (cdr x) 1))))
(define class-get-slots (lambda (x) (and (class? x) (vector-ref (cdr x) 2))))
(define class-get-vars  (lambda (x) (and (class? x) (vector-ref (cdr x) 3))))

(define class-set-vars  (lambda (x v) (and (class? x) (vector-set! (cdr x) 3 v))))

(define cons-of-caar (lambda (x) (cons (caar x) nil)))

(define class-generate-vars
  (lambda (x)
    (if (null? x)
	nil
	(append (map cons-of-caar (class-get-slots x)) (class-generate-vars (class-get-super x))))))

(define slot-show
  (lambda (x)
    (display "    slot=(")
    (let ((pair (car x)))
      (display (car pair))
      (display " ")
      (display (class-get-name (cdr pair))))
    (let ((guard (cdr x)))
      (if (not (null? guard))
	  (begin
	    (display " ")
	    (display (car guard)))))
    (display ")")
    (newline)))

(define class-show
  (lambda (x)
    (if (class? x)
	(begin
	  (display "class=") (print (class-get-name x))
	  (display "  super=") 
	  (let ((super (class-get-super x)))
	    (if (null? super)
		(print 'nil)
		(print (class-get-name super))))
	  (display "  vars=" ) (print (class-get-vars x))
	  (for-each slot-show (class-get-slots x))))))

(define class-image
  (lambda (x)
    (and (class? x)
      (let ((str-port (open-output-string)))
	(display "{cls " str-port)
	(display (class-get-name x) str-port)
	(display "@" str-port)
	(display (%object-address x) str-port)
	(display "}" str-port)
	(get-output-string str-port)))))

;;
;; <object>
;;

(define <object> (make-class '<object> nil nil))

;;
;; instance: (<class> . <env>)
;;

(define make-object
  (lambda (<class>)
    (let ((env (%make-environment (class-get-vars <class>) (the-global-environment))))
      (cons <class> env))))

(define object?
  (lambda (x)
    (and (pair? x) (class? (car x)))))

(define object-class
  (lambda (x)
    (if (object? x) 
	(car x)
	<object>)))

(define object-env
  (lambda (x)
    (and (object? x) (cdr x))))

(define object-bindings
  (lambda (x)
    (and (object? x) (environment-bindings (object-env x)))))

(define object-image
  (lambda (x)
    (and (object? x)
      (let ((str-port (open-output-string)))
	(display "{obj (" str-port)
	(display (class-get-name (object-class x)) str-port)
	(display ")" str-port)
	(display "@" str-port)
	(display (%object-address x) str-port)
	(display "}" str-port)
	(get-output-string str-port)))))
	

;;
;; syntax: (subclass? c1 c2)
;;
;;   is c1 a subclass of c2?

(define subclass?
  (lambda (c1 c2)
    (>= (deriv-distance c1 c2) 0)))

;;
;; Derivational Distance
;;
;;   compute the derivational distance of c1 from c2
;;     =0: the same class
;;     >0: a proper subclass
;;     <0: not a subclass
;;

(define deriv-distance
  (lambda (c1 c2)
    (letrec ((dist-aux
	      (lambda (c1 c2 d)
		(if (or (null? c1) (null? c2))
		    -1
		    (if (eq? c1 c2)
			d
			(dist-aux (class-get-super c1) c2 (+ d 1)))))))
      (dist-aux c1 c2 0))))

(define instance?
  (lambda (object class)
    (eq? (object-class object) class)))

;;
;; CLASS/SLOTS
;;

;;
;; parsed-slots -> (((<slot-name> . <type>) <guard-function>) ...)
;;

(define parse-slot
  (lambda (slot)
    (cond ((symbol? slot) 
	   ;; SLOT ((n . t))
	   (list (CONS slot <object>)))
	  ((pair? slot)
	   (let ((sname (car slot))
		 (stype (cadr slot))
		 (sguard (caddr slot)))
	     (if (not (symbol? sname))
		 (error "parse-slot--slot name not a symbol" slot)
		 (let ((type (%symbol-value stype))
		       guard)
		   (if (null? sguard)
		       (set! guard nil)
		       (if (bound? sguard)
			   (set! guard (%symbol-value sguard))
			   (error "parse-slot--symbol is unboud" sguard)))
		   (if (not (class? type))
		       (error "parse-slot--slot type is not a class" stype)
		       (if (null? guard)
			   ;; SLOT ((n . t))
			   (list (CONS sname type))
			   (if (procedure? guard)
			       ;; SLOT ((n . t) guard)
			       (list (CONS sname type) sguard))))))))
	  (else
	   (error "parse-slot--not a well-formed slot")))))

(define make-accessor-name
  (lambda (accessor slot-name)
    (string->symbol (string-append (symbol->string accessor) (symbol->string slot-name)))))

(define getter (lambda (slot-name) (make-accessor-name 'get- slot-name)))
(define setter (lambda (slot-name) (make-accessor-name 'set- slot-name)))

(define generate-getter
  (lambda (class slot)
    ;; closure = (lambda (x) (access <slot-var> (object-env x)))
    (let ((name (getter (car slot)))
	  (params (list (list 'this (class-get-name class))))
	  (body `((access ,(car slot) (object-env this)))))
      (fn:define-function name params body))))

(define setter-error (lambda (x) (error "setter value incorrect type" x)))
    
(define generate-setter
  (lambda (class slot guard)
    ;; closure = (lambda (x v) (set! (access <slot-var> (object-env x)) v))
    (let ((name (setter (car slot)))
	  (params (list (list 'this (class-get-name class)) (list 'val (class-get-name (cdr slot)))))
	  body)
      (if (null? guard)
	  (set! body `((set! (access ,(car slot) (object-env this)) 
			     val)))
	  (set! body `((set! (access ,(car slot) (object-env this)) 
			     (if (,guard val) val (setter-error val))))))
      (fn:define-function name params body))))

(define parse-super
  (lambda (super)
    (let ((type (%symbol-value super)))
      (if (class? type)
	  type
	  (error "parse-super:superclass is not a class" type)))))

(define fn:define-class
  (lambda (class super slots)
    (let ((super (parse-super super))
	  (parsed-slots (map parse-slot slots)))
      (let ((cx (make-class class super parsed-slots)))
	(class-set-vars cx (class-generate-vars cx))
	(%set-symbol-value! class cx)
	;; parsed-slots = ( ((n . t) g) ((n . t) g) ... )
	(while parsed-slots
	   (let ((slot (car parsed-slots)))
	     ;; slot = ((n . t) g)
	     (let ((slot-name-type (car slot))
		   (slot-guard (cadr slot)))
	       (generate-getter cx slot-name-type)
	       (generate-setter cx slot-name-type slot-guard)))
	   (set! parsed-slots (cdr parsed-slots)))
	class))))

;; [End of Classes and Objects]
;;=========================================================


;;=========================================================
;;  Generic Functions
;;
;;    Generic function table
;;    Generic function representation
;;    Parameter parsing
;;    Generic function installation
;;    Function definition
;;

;; syntax: (gf-find name params) --> ((nargs . <gentry>))
;; syntax: (gf-store name params) --> ((name . <by-num>))

;; syntax: (make-generic-function params) --> (params)
;; syntax: (gf-get-name by-name) --> symbol
;; syntax: (gf-get-entry by-name) --> by-num
;; syntax: (gf-get-sig gentry) --> sig
;; syntax: (gf-get-imps gentry) --> imps
;; syntax: (gf-set-sig gentry sig)
;; syntax: (gf-set-imps gentry imps)
;; syntax: (make-function sig imp) --> (sig . imp)
;; syntax: (get-function-sig func) --> sig
;; syntax: (get-function-imp func) --> imp
;; syntax: (gf-add-imp gentry imp)
;; syntax: (gf-imp-image imp) --> image
;; syntax: (gf-imp-show imp)
;; syntax: (gf-sig-show sig)
;; syntax: (gf-show by-name)
;; syntax: (generic-functions-show)
;; 
;; syntax: (parse-parameters params) -> normalized-parameters
;; syntax: (install-generic-function name params)
;; syntax: (fn:define-generic-function gfname gfparams)
;; syntax: (gf-add-function fname imp)
;; syntax: (fn:define-function fname fparams fbody)
;; syntax: (typed-function-apply typed-function args)
;; syntax: (fn:function fparams fbody)
;; syntax: (fn:add-function fname function)
;; syntax: (make-closure fparams fbody)
;; syntax: (check-type-eq gen imp) --> boolean
;; syntax: (find-exact-signature params imps) --> imps
;; syntax: (get-printable-params params) --> list-of-names-and-types
;;

;;
;;   Create a generic function named <name>
;;
;;   We store generic functions on an association list by name and number.
;;
;;     <by-name> := ((<name> . <by-num>) ... )     [1st assoc-list]
;;     <by-num>  := ((<nargs> . <gentry>)) ... )   [2nd assoc-list]
;;     <gentry>  := (<gsig> . <imps>)
;;     <imps>    := ((<isig> . <imp>) ...)
;;

(define %gfuncs nil)

;; find a gf by name and by number of params

(define gf-find
  (lambda (name params)
    (let ((by-name (assoc name %gfuncs)))
      (let ((by-num (assoc (length params) (cdr by-name))))
	(cdr by-num)))))

(define gf-store
  (lambda (name params gfunc)
    (let ((by-name (assoc name %gfuncs)))
      (if (null? by-name)
	  ;; no generic function with this name
	  (let ((by-num-entries (list (cons (length params) gfunc))))
	    ;; by-num-entries := ((<nargs> . <gentry>))
	    (set! by-name (cons name by-num-entries))
	    ;; by-name := (<name> . ((<nargs> . <gentry>)))
	    (set! %gfuncs (cons by-name %gfuncs))
	    ;; %gfuncs := ((<name> . <gentry>) ...)
	    )
	  ;; found by-name!
	  (let ((by-num (assoc (length params) (cdr by-name))))
	    (if (null? by-num)
		;; no generic function with this number of params
		(let ((by-num-entry (cons (length params) gfunc)))
		  ;; by-num-entry := (<nargs> . gfunc)
		  (set-cdr! by-name (cons by-num-entry (cdr by-name)))
		  ;; by-name := (<name> . ((<nargs> . gfunc)) ..)
		  )
		))
	  )
      by-name
      )
    ))

(define make-generic-function
  (lambda (params)
    (let ((functions nil))
      (cons params functions))))

;; x=(name . by-num)
(define gf-get-name  (lambda (x) (car x)))
(define gf-get-entry (lambda (x) (cdr x)))

;; x=gentry
(define gf-get-sig  (lambda (x) (car x)))
(define gf-get-imps (lambda (x) (cdr x)))
(define gf-set-sig  (lambda (x gsig) (set-car! x gsig)))
(define gf-set-imps (lambda (x imps) (set-cdr! x imps)))

;; function
(define make-function (lambda (sig imp) (cons sig imp)))
(define get-function-sig (lambda (x) (car x)))
(define get-function-imp (lambda (x) (cdr x)))

(define gf-add-imp 
  (lambda (x imp)
    (gf-set-imps x (cons imp (gf-get-imps x)))))

(define gf-imp-image 
  (lambda (<closure>)
    (if (not (closure? <closure>))
	(error "gf-imp-image--implemenation is not a closure" <closure>)
	(%closure-code <closure>))))

(define gf-imp-show
  (lambda (x)
    (display "  instance sig: ")
    (display (get-printable-params (get-function-sig x)))
    (display ", imp: ")
    ;;(print (gf-imp-image (get-function-imp x)))))
    (print (get-function-imp x))))

(define gf-sig-show
  (lambda (x)
    (display "  signature: ")
    (print (get-printable-params x))))

(define gf-show
  (lambda (x)
    (display "name: ")
    (print (gf-get-name x))
    (let ((gf-show-n-entry 
	   (lambda (x)
	     (display "  nargs: ")
	     (print (car x))
	     (let ((x (cdr x)))
	       (gf-sig-show (gf-get-sig x))
	       (map gf-imp-show (gf-get-imps x))
	       ))))
      (map gf-show-n-entry (gf-get-entry x)))))

(define generic-functions-show
  (lambda ()
    (for-each gf-show %gfuncs)))

;;
;; PARAMETERS
;;
;;   (a (b t1) (c t2) ... ) --> ((a . <object>) (b . t1) (c . t2) ... )
;;

(define parse-parameters
  (lambda (x)
    (cond ((null? x) nil)
	  ((pair? x)
	   (let ((param (car x)))
	     (cond ((symbol? param) 
		    ;; PARAM (n . <object>)
		    (cons (CONS param <object>) (parse-parameters (cdr x))))
		   ((and (pair? param) (= (length param) 2))
		    (let ((pname (car param))
			  (ptype (cadr param)))
		      (if (and (symbol? pname) (symbol? ptype))
			  (let ((ptype (%symbol-value ptype)))
			    (if (not (class? ptype))
			      (error "parse-parameters--parameter type is not a class" slot)
			      ;; PARAM (n . t)
			      (cons (CONS pname ptype) (parse-parameters (cdr x)))))
			  (error "parse-parameters--ill-formed parameter group" param))))
		   (else
		    (error "parse-parameters--ill-formed parameter" param)))))
	  (else
	    (error "iparse-parameters--ill-formed parameter list" x)))))

;;
;; note: install-generic-function should only be called, if no such pattern exists.
;;

(define install-generic-function
  (lambda (name params)
    (let ((gf-func (make-generic-function params)))
      (let ((by-name (gf-store name params gf-func)))
	(let ((global-gfunc-dispatcher (lambda args (gf-dispatch by-name args))))
	  (%set-symbol-value! name global-gfunc-dispatcher))
	gf-func
	))))

(define fn:define-generic-function
  (lambda (gfname gfparams)
    (let ((gfparams (parse-parameters gfparams)))
      (if (gf-find gfname gfparams)
	  (warning "generic function already defined" gfname))
      (install-generic-function gfname gfparams)
      gfname
    )))

(define gf-add-function
  (lambda (fname imp)
    (let ((fparams (get-function-sig imp)))
      (let ((gf (gf-find fname fparams)))
	(if (null? gf)
	    (set! gf (install-generic-function fname fparams)))
	(let ((imps (find-exact-signature fparams (gf-get-imps gf))))
	  (if imps
	      (set-car! imps imp)  ;; replace
	      (gf-add-imp gf imp)  ;; add anew
	      )))
      fname
      )))
  
(define fn:define-function
  (lambda (fname fparams fbody)
    (set! fparams (parse-parameters fparams))
    (let ((imp (make-function fparams (make-closure fparams fbody))))
      (gf-add-function fname imp))))

(define typed-function-apply
  (lambda (typed-function args)
    (let ((params (get-function-sig typed-function)))
    (if (not (= (length params) (length args)))
	(error "tf-apply--typed function argument count mismatch"))
    (let ((argtypes (map object-class args)))
      (let ((val (gf-evaluate argtypes params)))
	(if (< val 0)
	    (error "tf-apply--argument type mismatch"))
      (let ((closure (get-function-imp typed-function)))
	(apply closure args)))))
    ))

(define fn:function
  (lambda (fparams fbody)
    (set! fparams (parse-parameters fparams))
    (let ((imp (make-function fparams (make-closure fparams fbody))))
      (let ((typed-function-applicator
	     (lambda args
	       (typed-function-apply imp args))))
	typed-function-applicator
	))))

(define fn:add-function
  (lambda (fname function)
    (let ((imp (access imp (procedure-environment function))))
      (gf-add-function fname imp))))

(define make-closure
  (lambda (fparams fbody)
    (let ((closure (cons 'lambda (cons (map car fparams) fbody))))
      (eval closure))))

(define check-type-eq
  (lambda (gen imp)
    (if (null? gen)
	#t
	(if (not (eq? (cdar imp) (cdar gen)))
	    #f
	    (check-type-eq (cdr gen) (cdr imp))))))

(define find-exact-signature
  (lambda (params imps)
    (if (null? imps)
	#f
	(if (check-type-eq params (caar imps))
	    imps
	    (find-exact-signature params (cdr imps))))))

(define get-printable-params
  (lambda (params)
    (if (null? params)
	nil
	(let ((param (car params)))
	  (let ((name (car param))
		(type (class-get-name (cdr param))))
	    (cons (list name type) (get-printable-params (cdr params))))))))

;; [End of Generic Functions]
;;=========================================================


;;=========================================================
;; Function Dispatch
;;
;;   Function signature evaluation
;;   Candidate list
;;   Candidate list sort
;;   Dispatch
;;   Next function
;;
;; syntax: (gf-evaluate argtypes fparams)
;; syntax: (cv-init)
;; syntax: (cv-add value function)
;; syntax: (cv-sort2 v vlen)
;; syntax: (cv-sort)
;; syntax: (gf-dispatch n-entries args)
;; syntax: (next-function)
;;

;;
;; Candidate vector: 
;;   cv-vector
;;     #( val1 fun1 val2 fun2 ... valN funN )
;;
;; Current index: 
;;   cv-current
;;     initial     cv-current = 0
;;     update:     cv-current += 2
;;     evaluation: v[cv-current]
;;     funtion:    v[cv-current+1]
;;

(define gf-evaluate
  (lambda (argtypes fparams)
    (let ((result 0))
      (while (and fparams (>= result 0))
	     (let ((d (deriv-distance (car argtypes) (cdar fparams))))
	       (if (>= d 0)
		   (begin
		     (set! result (+ result d))
		     (set! argtypes (cdr argtypes))
		     (set! fparams (cdr fparams)))
		   (begin
		     (set! result -1)))
	       ))
      result
      )))

(define cv-current 0)
(define cv-last 0)
(define cv-vector (make-vector 100))
(define cv-best-val 999)
(define cv-best-imp nil)
(define cv-args nil)

(define cv-init
  (lambda ()
    (set! cv-current 0)
    (set! cv-last 0)
    (set! cv-best-val 999)
    (set! cv-best-imp nil)
    ))

(define cv-add
  (lambda (value function)
    (if (> (+ cv-last 2) (vector-length cv-vector))
	(error "cv-add--candidate vector length exceeded" (cons value function)))
    (vector-set! cv-vector cv-last value)
    (vector-set! cv-vector (+ cv-last 1) function)
    (set! cv-last (+ cv-last 2))))

(define cv-sort2
  (lambda (v vlen)
    (let ((i 0)
	  (vlen-2 (- vlen 2)))
      (while (< i vlen-2)
	 (let ((j (+ i 2)))
	   (while (< j vlen)
	      (if (> (vector-ref v i) (vector-ref v j))
		  (let (temp)
		    (set! temp (vector-ref v i))
		    (vector-set! v i (vector-ref v j))
		    (vector-set! v j temp)
		    (let ((ip1 (inc i))
			  (jp1 (inc j)))
		      (set! temp (vector-ref v ip1))
		      (vector-set! v ip1 (vector-ref v jp1))
		      (vector-set! v jp1 temp))
		    ))
	      (set! j (+ j 2))))
	 (set! i (+ i 2))))))

(define cv-sort
  (lambda ()
    (cv-sort2 cv-vector cv-last)))

(define gf-dispatch
  (lambda (n-entries args)
    (let ((gf (cdr (assoc (length args) n-entries))))
      (let ((gfparams (gf-get-sig gf))
	    (argtypes (map object-class args)))
	(let ((imps (gf-get-imps gf)))
	  ;; accumulate a list of candidates
	  (cv-init)
	  (set! cv-args args)
	  (while imps
	     (let ((imp (car imps)))
	       (let ((val (gf-evaluate argtypes (get-function-sig imp))))
		 (if (>= val 0)
		     (begin
		       (cv-add val imp)
		       (if (< val cv-best-val)
			   (begin
			     (set! cv-best-val val)
			     (set! cv-best-imp imp)))))))
	     (set! imps (cdr imps)))
	  (if (= cv-last 0)
	      (error "dispatch--no generic implementation found for" (map class-get-name argtypes))
	      (let ((closure (get-function-imp cv-best-imp)))
		(apply closure args)))
	  ))
      )))

;;
;; NEXT FUNCTION
;;

(define next-function
  (lambda ()
    ;; we only sort the candiates, if next-function is called
    (if (= cv-current 0)
	(begin 
	  (cv-sort) 
	  (set! cv-current 2)))
    (if (>= cv-current cv-last)
	(error "no next function"))
    (let ((closure (get-function-imp (vector-ref cv-vector (+ cv-current 1)))))
      (set! cv-current (+ cv-current 2))
      (apply closure cv-args)
      )))

;; [End of Function Dispatch]
;;=========================================================


;;
;; MACROS
;;

(macro define-class
  (lambda (form)
    (let ((cname (cadr form))
	  (super (caddr form))
	  (slots (cadddr form)))
      `(fn:define-class ',cname ',super ',slots))))

(macro define-generic-function
  (lambda (form)
    (let ((gfname (cadr form))
	  (gfparams (caddr form)))
      `(fn:define-generic-function ',gfname ',gfparams))))

(macro define-function
  (lambda (form)
    (let ((fname (cadr form))
	  (fparams (caddr form))
	  (fbody (cdddr form)))
      `(fn:define-function ',fname ',fparams ',fbody))))

(macro function
  (lambda (form)
    (let ((fparams (cadr form))
	  (fbody (cddr form))
	  )
      `(fn:function ',fparams ',fbody))))

(macro add-function
  (lambda (form)
    (let ((fname (cadr form))
	  (fn (caddr form)))
      `(fn:add-function ',fname ,fn))))

;;
;; (make <class> <name-value-pairs>)
;;
;;   <name-value-pairs> := <name-value-pair> ...
;;   <name-value-pair> := (<ivar> <value>)
;;

(define create-init-pair
  (lambda (object <pair>)
    (if (not (pair? <pair>))
	(error "create-init-pair--not an initializer pair" <pair>)
	(let ((name (car <pair>))
	      (value (cadr <pair>)))
	  (if (not (symbol? name))
	      (error "create-init-pair--not a symbol" name)
	      `(,(setter name) ,object ,value))))))

(define create-init-pairs
  (lambda (object <pairs>)
    (if (null? <pairs>)
	nil
	(cons (create-init-pair object (car <pairs>))
	      (create-init-pairs object (cdr <pairs>))))))

(macro make
  (lambda (form)
    (let ((<class> (cadr form))
	  (<pairs> (cddr form))
	  (object (gensym "%%g")))
      `(let ((,object (make-object ,<class>)))
	 ,@(create-init-pairs object <pairs>)
	 ,object)
      )))

;;
;; Unchecked Slot Operations
;;

(macro slot-ref
  (lambda (form)
    (let ((slot (cadr form))
	  (object (caddr form)))
      `(access ,slot (object-env ,object)))))

(macro slot-set!
  (lambda (form)
    (let ((slot (cadr form))
	  (object (caddr form))
	  (value (cadddr form)))
      `(set! (access ,slot (object-env ,object)) ,value))))

