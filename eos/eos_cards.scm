(load "./eos.scm")

;;
;; Classes
;;   <card>
;;   <deck>
;;
;; Functions
;;   (show <card>)
;;   (red? <card>)
;;   (black? <card>)
;;
;;   (make-deck)
;;   (show <deck>)
;;   (add <deck> <card>)
;;   (shuffle <deck>)
;;   (peek-top <deck>)
;;   (get-top <deck>)
;;

(generic-functions-show)

(define suites '(spade heart diamond club))
(define denoms '(A 2 3 4 5 6 7 8 9 10 J Q K))

(define-class <card> <object> ((suite <object>) (denom <object>)))

(define-function show ((card <card>))
  (display "card{ ")
  (display (get-denom card))
  (display ", ")
  (display (get-suite card))
  (display " }")
  (newline))

(define c1 (make <card> (suite 'spade) (denom 'A)))
(define c2 (make <card> (suite 'heart) (denom 'K)))
(define c3 (make <card> (suite 'club)  (denom '9)))

(show c1)
(show c2)
(show c3)

(define-function red? ((card <card>))
  (member (get-suite card) '(heart diamond)))

(define-function black? ((card <card>))
  (member (get-suite card) '(spade club)))

(red? c1)
(red? c2)
(black? c1)
(black? c2)

(define-class <deck> <object> ((cards <object>)))

(define-function make-deck ()
  (let (cards)
    (let ((ss suites))
      (while 
       ss
       (let ((dd denoms))
	 (while 
	  dd
	  (set! cards (cons (make <card> 
			      (suite (car ss)) 
			      (denom (car dd))) cards))
	  (set! dd (cdr dd))))
       (set! ss (cdr ss))))
    (make <deck> (cards cards))
    ))

(define d1 (make-deck))

(define-function show ((deck <deck>))
  (let ((cards (list->vector (get-cards deck)))
	(i 0))
    (while (< i (vector-length cards))
       (show (vector-ref cards i))
       (set! i (+ i 1)))
  ))

(show d1)

(define-function add ((deck <deck>) (card <card>))
  (set-cards deck (cons card (get-cards deck)))
  card)

(define-function shuffle ((deck <deck>))
  (let ((cards (list->vector (get-cards deck))))
    (let ((i (- (vector-length cards) 1)))
      (while (> i 0)
	     ;; swap card[i] with card[random(i)]
	     (let ((j (random i)))
	       (let ((c1 (vector-ref cards i))
		     (c2 (vector-ref cards j)))
		 (vector-set! cards j c1)
		 (vector-set! cards i c2)))
	     (set! i (- i 1))))
    (set-cards deck (vector->list cards))
    deck
    ))

(show d1)
(show (shuffle d1))
(show (shuffle d1))

(define-function peek-top ((deck <deck>))
  (car (get-cards deck)))

(define-function get-top ((deck <deck>))
  (let ((top (peek-top deck)))
    (set-cards deck (cdr (get-cards deck)))
    top
  ))

(show (peek-top d1))
(show (get-top d1))

(show (peek-top d1))
(show (get-top d1))

(show (peek-top d1))

(define d2 (make <deck>))

(show d2)

(add d2 c1)
(add d2 c2)
(add d2 c3)

(show (shuffle d2))

(generic-functions-show)

;; [EOF]