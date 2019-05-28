(load "./xos.scm")

;;
;; Classes
;;   <card>
;;   <deck>
;;
;; Methods
;;   (<card> 'show)
;;   (<card> 'red?)
;;   (<card> 'black?)
;;
;;   (make-deck)
;;   (<deck> 'show)
;;   (<deck> 'add <card>)
;;   (<deck> 'shuffle)
;;   (<deck> 'peek-top)
;;   (<deck> 'get-top)
;;

(define suites '(spade heart diamond club))
(define denoms '(A 2 3 4 5 6 7 8 9 10 J Q K))

(define <card> (class 'new '(suite denom)))

(<card> 'method 'init '(suite denom) 
	'((slot-set! self 'suite suite) 
	  (slot-set! self 'denom denom) 
	  self))

(<card> 'method 'show '()
	'((display "card{ ")
	  (display (slot-ref self 'denom))
	  (display ", ")
	  (display (slot-ref self 'suite))
	  (display " }")
	  (newline)
	  self))

(define c1 (<card> 'new 'spade 'A))
(define c2 (<card> 'new 'heart 'K))
(define c3 (<card> 'new 'club  '9))

(c1 'show)
(c2 'show)
(c3 'show)

(<card> 'method 'red?   '() '((member (slot-ref self 'suite) '(heart diamond))))
(<card> 'method 'black? '() '((member (slot-ref self 'suite) '(spade club))))

(c1 'red?)
(c2 'red?)
(c1 'black?)
(c2 'black?)

(define <deck> (class 'new '(cards)))

(<deck> 'method 'init '(cards) 
	'((slot-set! self 'cards cards) self))

(define make-deck
  (lambda ()
    (let (cards)
      (let ((ss suites))
	(while 
	   ss
	   (let ((dd denoms))
	     (while 
	       dd
	       (set! cards (cons (<card> 'new (car ss) (car dd)) cards))
	       (set! dd (cdr dd))))
	   (set! ss (cdr ss))))
      (<deck> 'new cards)
      )))

(define d1 (make-deck))

(<deck> 'method 'show '()
	'((let ((cards (list->vector (slot-ref self 'cards)))
		(i 0))
	    (while (< i (vector-length cards))
	       ((vector-ref cards i) 'show)
	       (set! i (1+ i))))))

(d1 'show)

(<deck> 'method 'add '(card) 
	'((slot-set! self 'cards (cons card (slot-ref self 'cards)))))

(<deck> 'method 'shuffle '()
	'((let ((cards (list->vector (slot-ref self 'cards))))
	    (let ((i (- (vector-length cards) 1)))
	      (while (> i 0)
		     ;; swap card[i] with card[random(i)]
		     (let ((j (random i)))
		       (let ((c1 (vector-ref cards i))
			     (c2 (vector-ref cards j)))
			 (vector-set! cards j c1)
			 (vector-set! cards i c2)))
		     (set! i (- i 1))))
	    (slot-set! self 'cards (vector->list cards))
	    self
	    )))

(d1 'show)
((d1 'shuffle) 'show)
((d1 'shuffle) 'show)

(<deck> 'method 'peek-top '() 
	'((car (slot-ref self 'cards))))

(<deck> 'method 'get-top  '() 
	'((let ((top (self 'peek-top))) 
	    (slot-set! self 'cards (cdr (slot-ref self 'cards))) 
	    top)))

((d1 'peek-top) 'show)
((d1 'get-top) 'show)

((d1 'peek-top) 'show)
((d1 'get-top) 'show)

((d1 'peek-top) 'show)

(define d2 (<deck> 'new nil))

(d2 'show)

(d2 'add c1)
(d2 'add c2)
(d2 'add c3)

(d2 'show)
((d2 'shuffle) 'show)


;; [EOF]

