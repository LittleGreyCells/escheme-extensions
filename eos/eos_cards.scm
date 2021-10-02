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

(load "../escheme-extensions/eos/eos.scm")

(generic-functions-show)

(define suites '(spade heart diamond club))
(define denoms '(A 2 3 4 5 6 7 8 9 10 J Q K))

(define-class <card> <object> ((suite <object>) (denom <object>)))

(define-method init ((this <card>) s d)
  ((setter suite) this s)
  ((setter denom) this d))

(define-method show ((card <card>))
  (display "card{ ")
  (display (denom card))
  (display ", ")
  (display (suite card))
  (display " }")
  (newline))

(define c1 (make <card> 'spade 'A))
(define c2 (make <card> 'heart 'K))
(define c3 (make <card> 'club  '9))

(show c1)
(show c2)
(show c3)

(define-method red? ((card <card>))
  (member (suite card) '(heart diamond)))

(define-method black? ((card <card>))
  (member (suite card) '(spade club)))

(red? c1)
(red? c2)
(black? c1)
(black? c2)

(define-class <deck> <object> ((cards <object>)))

(define-method init ((this <deck>) cs)
  ((setter cards) this cs))

(define-method make-deck ()
  (let (cs)
    (for-each
     (lambda (s)
       (for-each
	(lambda (d) (set! cs (cons (make <card> s d) cs)))
	denoms))
     suites)
     (make <deck> cs)
    ))

(generic-functions-show)

(define d1 (make-deck))

(define-method show ((deck <deck>))
  (for-each
   (lambda (c)
     (show c))
   (cards deck)))

(show d1)

(define-method add ((deck <deck>) (card <card>))
  ((setter cards) deck (cons card (cards deck)))
  card)

(define-method shuffle ((deck <deck>))
  (let ((cards (list->vector (cards deck))))
    (let ((i (- (vector-length cards) 1)))
      (while (> i 0)
	     ;; swap card[i] with card[random(i)]
	     (let ((j (random i)))
	       (let ((c1 (vector-ref cards i))
		     (c2 (vector-ref cards j)))
		 (vector-set! cards j c1)
		 (vector-set! cards i c2)))
	     (set! i (- i 1))))
    ((setter cards) deck (vector->list cards))
    deck
    ))

(show (shuffle d1))
(show (shuffle d1))
(show (shuffle d1))

(define-method peek-top ((deck <deck>))
  (car (cards deck)))

(define-method get-top ((deck <deck>))
  (let ((top (peek-top deck)))
    ((setter cards) deck (cdr (cards deck)))
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
