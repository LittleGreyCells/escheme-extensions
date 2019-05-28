;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Additional Examples
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "./eos.scm")

(generic-functions-show)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Example 1) Stack of Any Type
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; define a <stack> class
(define-class <stack> <object> (data))
(class-show <stack>)

;; create classic stack operations
(define-function push ((stack <stack>) item) 
  (set-data stack (cons item (get-data stack))))

(define-function pop ((stack <stack>))
  (let ((item (car (get-data stack))))
    (set-data stack (cdr (get-data stack)))
    item))

;; create an instance
(define stack1 (make <stack>))
(push stack1 1)

(if (not (= 1 (pop stack1)))
    (error "push/pop item different" stack1))

;;
;; note: redefinitions "replace" existing definitions
;;

(push stack1 1)
(push stack1 2)

;; the following generates an error, because 1 was not the last item pushed; 
;;   2 was.
(if (not (= 1 (pop stack1)))
    (error "push/pop item different" stack1))

;; this succeeds
(if (not (= 1 (pop stack1)))
    (error "push/pop item different" stack1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Example 2) Stack of Type integer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "./eos/eos.scm")

(generic-functions-show)

;; Achieved "type-saftey" by
;;   1. creating a stack intended to be dedicated to integer content
;;   2. writing a modifier (push) which takes (<stack-of-integer>, <integer>)
;;      arguments
;;

(define-class <integer> <object> ((x <object> integer?)))

;; we want to constrain a stack to only accept type integer

;; define a <stack> class
(define-class <stack-of-integer> <object> (data))
(class-show <stack-of-integer>)

;; create stack operations -- this constrains
(define-function push ((stack <stack-of-integer>) (item <integer>)) 
  (set-data stack (cons item (get-data stack))))

(define-function pop ((stack <stack-of-integer>))
  (let ((contents (get-data stack)))
    (let ((item (car contents)))
      (set-data stack (cdr contents))
      item)))

;; create an instance
(define stack2 (make <stack-of-integer>))

;; the following should cause an error
(push stack2 'a)

;; the following will not
(push stack2 (make <integer> (x 100)))

(define x (pop stack2))

(if (not (= (get-x x) 100))
    (error "push/pop item different" stack2))

(print (get-x x))

;; [EOF]


