(define (xregkey key command)
	(xbindkey-function key
		(lambda ()
			(run-command command)
			(set! ACTED #t)
		)
	)
)

(define (xregkey-func key func)
	(xbindkey-function key
		(lambda ()
			(func)
			(set! ACTED #t)
		)
	)
)

(define (xmodekey key command)
	(xbindkey-function key
		(lambda ()
			(run-command command)
			(regmode)
		)
	)
)

(define (xmodekey-func key func)
	(xbindkey-function key
		(lambda ()
			(func)
			(regmode)
		)
	)
)

(define (regmode)
	(remove-all-keys)
	(ungrab-all-keys)

	(xbindkey-function PRESS (lambda () (set! ACTED #f)))
	(xbindkey-function RELEASE altmode)

	(bindregkeys)

	(grab-all-keys)
)

(define (altmode)
	(cond
		((not ACTED)
			(remove-all-keys)
			(ungrab-all-keys)

			(bindmodekeys)

			(grab-all-keys)
		)
	)
)

(define ACTED #f)

(regmode)
