; it is necesary to define a press and a release bind because xbindkeys
; counts modifier keys as includeing their own modifier on release, but
; not on press (e.g.: Alt_L is pressed, but Alt+Alt_L is released).
; If you use something other than a modifier key for enabling modal
; mode, just set RELEASE equal to PRESS

(define PRESS '(Alt_L))
(define RELEASE '(Release Alt Alt_L))

(define MOD 'Alt)

(define (bindregkeys)
	(xregkey '(MOD s) "xbindkey_show")
)

(define (bindmodekeys)
	(xmodekey 't "xterm")
)

; each key in the sequence is equivalent to a key passed to xbindkey, so
; chords can be lists (if you're the kind of maniac who wants to enter a
; sequence of chords)
(define (bindmodesequences)
	(xmodseq '(o t) "rxvt")
)

(load "/home/drew/Documents/xmodekeys/xmodekeys.scm")
