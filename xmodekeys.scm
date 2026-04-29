; This is my terrible recursive modality engine "xmodekeys"
; Copyright 2026 Andrew Charles Marino Under MIT License

(define (xregkey key funcmand)
	(xbindkey-function key
		(lambda ()
			(if (string? funcmand)
				(run-command funcmand)
				(funcmand)
			)
			(set! ACTED #t)
		)
	)
)

(define (xmodeseq keys command)
	(set! ALLSEQ (append ALLSEQ (list (cons keys command))))
	(for-each
		(lambda (i)
			(if (not (memq i ALLKEY))
				(set! ALLKEY (append ALLKEY (list i)))
			)
		)
		keys
	)
)

(define (register-keys)
	(for-each
		(lambda (i)
			(xbindkey-function i
				(lambda ()
					(set! INPSEQ (append INPSEQ (list i)))
					(xcheckseq)
				)
			)
		)
		ALLKEY
	)
)

(define (xcheckseq)
	(for-each
		(lambda (i)
			(cond
				((equal? (car i) INPSEQ)
					; lisp is such a ridiculous language, not that i
					; wouldn't have done the same thing in C (with some
					; struct containing void* and char*, and a test
					; against the NULLness of the two, but this is just
					; ridiculous
					(if (string? (cdr i))
						(run-command (cdr i))
						((cdr i))
					)
					(regmode)
				)
			)
		)
		ALLSEQ
	)
)

(define (go-back)
	(set! GOINGBACK #t)
	(regmode)
)

(define (regmode)
	(remove-all-keys)
	(ungrab-all-keys)

	(xbindkey-function PRESS
		(lambda ()
			(set! ACTED #f)
			(set! GOINGBACK #f)
		)
	)
	(xbindkey-function RELEASE altmode)

	(if (defined? 'bindregkeys)
		(bindregkeys)
	)

	(grab-all-keys)
)

(define (altmode)
	(cond
		((and (not ACTED) (not GOINGBACK))
			(remove-all-keys)
			(ungrab-all-keys)

			; no clue why i have to do this but it doesn't work right if
			; either is missing, feeling inclined to chock it up to
			; xbindkeys being a little funky with presses and releases
			; of modkeys
			(xbindkey-function RELEASE go-back)
			(xbindkey-function (cons 'Release PRESS) go-back)

			(set! INPSEQ '())
			(register-keys)

			(grab-all-keys)
		)
	)
)

(define ACTED #f)
(define GOINGBACK #f)
(define INPSEQ '())
(define ALLSEQ '())
(define ALLKEY '())

(if (defined? 'bindmodesequences)
	(bindmodesequences)
)

; my only point of fear (that i have only one is proof of my madness
; resulting from use of this horrid tongue) is that the infinite
; recursion of regmode and altmode is a bad thing (though in lisp-land
; perhaps a "recursive modality engine" is something to be admired).
(regmode)
