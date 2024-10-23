; we are compiling for 65C02
.pc02

; We borrow kernal.inc (along with its dependency, fb.inc),
; and banks.inc file from the KERNAL source.

.include "banks.inc"
.include "kernal.inc"

; we need a couple of additional constants
ram_bank = $00
rom_bank = $01

; We are telling ca65/cl65 to never translate strings between ASCII and PETSCII
.include "ascii_charmap.inc"

; This will go at the beginning of the file for BANK $20
.segment "CARTSIG"
.byte "CX16"

; This is our entry point.  If you create other source files that use
; this segment, you must put main.s first in your assemble command line
; so that the first code in CART_20 is the code in this file.
.segment "CART_20"
; We wrap our bank functions in scopes so that we can use a single source file
; but have local copies of jsrfar inside each bank (which would otherwise
; have duplicate names with the doubly-included file).
.scope cart_20
    jmp start

; jsrfar.inc, which is also borrowed from the ROM source must live in every
; cart bank that needs to jump to other ROM code

myjsrfar:
.include "jsrfar.inc"

start:
    ; switch to ISO mode
    lda #$0f
    ; all KERNAL calls must go through jsrfar to ROM BANK 0
    ; you can add your own trampoline functions so that it doesn't
    ; require the 3 extra bytes in code for every call
    ; but in this example, I'm spelling it all out each time
    ; for clarity on what it's doing
    jsr myjsrfar
    .addr bsout
    .byte BANK_KERNAL

    ; Now, we jsrfar to our own code in bank $21
    jsr myjsrfar
    .addr do_hello_world
    .byte $21

    ; Now we return to our caller, which should load BASIC :)
    rts
.endscope

.segment "CART_21"
.scope cart_21
myjsrfar:
.include "jsrfar.inc"

do_hello_world:
    ldx #0
loop:
    lda hello_string,x
    beq done

    jsr myjsrfar
    .addr bsout
    .byte BANK_KERNAL

    inx
    bra loop
done:

waitforkey:
    jsr myjsrfar
    .addr getin
    .byte BANK_KERNAL

    beq waitforkey

    rts

hello_string:
    .byte "HELLO WORLD!",13
    .byte "PRESS ANY KEY TO CONTINUE",13,0
.endscope

; This is a workaround to ca65's limitation that a scope
; must be seen before it can be referenced.
;
; The other option would have been to put scope cart_21
; before scope cart_20, or split the source into multiple
; files and use .import and .export

do_hello_world := cart_21::do_hello_world
