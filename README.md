# xmodekeys

**xmodekeys** is a scheme script that allows xbindkeys to have modal
key bindings.

The two modes: regular and "modal" allow for two different key binding
schemes: regular is chords, single keys, and the like; while "modal"
is for key sequences (whose constituent parts may be chords)

One important thing to note is that switching from regular and
"modal" mode occurs when releasing the `RELEASE` (\*see Variables)
key, and switching from "modal" to regular mode occurs when pressing
the PRESS key.

## Configuring

Configuring **xmodekeys** is a touch different from xbindkeys chiefly
because **xmodkeys** rebinds all keys when switching between regular
and "modal" modes.

### Procedures
**(bindregkeys)**
: the `bindregkeys` procedure should be defined prior to loading
xmodekeys, it is run when switching from "modal" to regular mode, and
should use `xregkey` to define bindings (however, `xbindkey` *can* be
used to create bindings in regular mode that drop the user into "modal"
mode after executing. Any bindings made outside of either this, or the
`bindmodesequences` procedures will be erased when switching modes.

**(xregkey *list* *string/procedure*)**
: the `xregkey` procedure binds a single chord to either a command to run
(like `xbindkey`) or a procedure (`xbindkey-func`), but as a single
procedure

**(bindmodesequences)**
: the `bindmodesequences` procedure should be defined prior to loading
xmodekeys, it is run when switching from regular to "modal" mode, and
should use `xmodeseq` to bind key sequences (`xbindkey` can be used to
create functions that do not return to regular mode after executing).
Any bindings made outside of either this, or the `bindregkeys`
procedures will be erased when switching modes.

**(xmodeseq *list* *string/procedure*)**
: the `xmodeseq` procedure binds a list of keys and/or chords to
either a command or procedure (like `xregkey`).

**(regmode)**
: immediately places the user into regular mode, called after every
binding bound with `xmodeseq`

**(altmode)**
: immediately places the user into "modal" mode, called if certain
conditions match after the `RELEASE` (\*see Variables) has been
released. Those conditions are: a binding made with `xregkey` has NOT
been triggered, and the `PRESS` key was not pressed while in "modal"
mode.

### Variables

**PRESS**
: this should be whatever key or chord you wish to use to switch
between regular and "modal" mode

**RELEASE**
: this should be whatever key or chord you wish to use to switch
between regular and "modal" mode, BUT with the `Release` modifier
added. This is needed because xbindkeys recognizes modifier key
PRESSES as being without modifiers, but RELEASES as having them. So
pressing left control appears as just `Control_L`, but releasing it is
`Release + Control + Control_L`. As such, if you (and you most likely
do) wish to use a modifier key as the key to switch between modes,
`PRESS` should be set to `'Alt_L` (for this example), and `RELEASE` to
`'(Release Alt Alt_L)`.

**NOTELL**
: defining this at all disables the "Telling" feature (\*see Telling)

## Telling

This feature can be disabled by defining the `NOTELL` variable.

The file /tmp/xmodekeys can be read to figure out the current state of
xmodekeys, It contains a single NULL character when xmodekeys is in
regular mode, and the current input sequence (keys separated by
spaces, modifiers by plus signs) when in "modal" mode.
