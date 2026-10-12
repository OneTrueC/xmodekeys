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
			(if (not (member i ALLKEY))
				(set! ALLKEY (append ALLKEY (list i)))
			)
		)
		keys
	)
)

(define (strcon-proc-delim listmaybe proc delim . extraargs)
	(letrec
		(
			(listyes (if (list? listmaybe) listmaybe (list listmaybe)))
			(return (apply proc (cons (car listyes) extraargs)))
		)

		(for-each
			(lambda (i)
				(set! return (string-append return (string-append delim (apply proc (cons i extraargs)))))
			)
			(cdr listyes)
		)
		return
	)
)

(define (announce)
	(if (not (defined? 'NOTELL))
		(run-command "echo '' > /tmp/xmodekeys")
	)
)

(define (unannounce)
	(if (not (defined? 'NOTELL))
		(run-command "echo 'NORMAL' > /tmp/xmodekeys")
	)
)

(define (writekeys)
	(if (not (defined? 'NOTELL))
		(let
			(
				(str (strcon-proc-delim INPSEQ strcon-proc-delim " " symbol->string "+"))
			)
			(run-command (string-append "echo '" (string-append str "' > /tmp/xmodekeys")))
		)
	)
)

(define (register-keys)
	(for-each
		(lambda (i)
			(xbindkey-function i
				(lambda ()
					(set! INPSEQ (append INPSEQ (list i)))
					(writekeys)
					(xcheckseq)
				)
			)
		)
		ALLKEY
	)
)

(define (subl l n)
	(let ((ret '()) (i 0))
		(for-each
			(lambda (itr)
				(cond
					((< i n)
						(set! i (+ i 1))
						(set! ret (append ret (list itr)))
					)
				)
			)
			l
		)
		ret
	)
)

(define (xcheckseq)
	(set! CULL
		(filter
			(lambda (i)
				(letrec
					(
						(seq (car i))
						(len (if (< (length seq) (length INPSEQ)) (length seq) (length INPSEQ)))
					)
					(equal? (subl seq len) (subl INPSEQ len))
				)
			)
			CULL
		)
	)

	(cond
		((= (length CULL) 1)
			(if (equal? (car (car CULL)) INPSEQ)
				(let ((funcmand (cdr (car CULL))))
					(if (string? funcmand)
						(run-command funcmand)
						(funcmand)
					)
					(regmode)
				)
			)
		)
		((= (length CULL) 0)
			(regmode)
		)
	)
)

(define (regmode)
	(unannounce)
	(remove-all-keys)
	(ungrab-all-keys)

	(xbindkey-function PRESS
		(lambda ()
			(set! ACTED #f)
		)
	)
	(xbindkey-function RELEASE
		(lambda ()
			(if (not FROMALT)
				(altmode)
				(set! FROMALT #f)
			)
		)
	)

	(if (defined? 'bindregkeys)
		(bindregkeys)
	)

	(grab-all-keys)
)

(define (altmode)
	(cond
		((not ACTED)
			(announce)
			(remove-all-keys)
			(ungrab-all-keys)

			; this is new directionwise but my idea here is that
			; regmode will always be active while PRESS is pressed, but
			; pressing and releasing PRESS when starting in altmode will
			; still return to regmode
			(xbindkey-function PRESS (lambda () (set! FROMALT #t) (regmode)))

			; i think culling will be more efficient with larger sets
			; of bindings because checking is only performed against the
			; subset of all bindings that could match the eventual
			; input sequence. it also allows for vim style returns to normal
			; mode when there are no bindings that could possibly match
			; the current input sequence
			(set! CULL ALLSEQ)
			(set! INPSEQ '())
			(register-keys)

			(grab-all-keys)
		)
	)
)

(define ACTED #f)
(define FROMALT #f)
(define INPSEQ '())
(define ALLSEQ '())
(define CULL '())
(define ALLKEY '())

(if (defined? 'bindmodesequences)
	(bindmodesequences)
)

; my only point of fear (that i have only one is proof of my madness
; resulting from use of this horrid tongue) is that the infinite
; recursion of regmode and altmode is a bad thing (though in lisp-land
; perhaps a "recursive modality engine" is something to be admired).
(regmode)
