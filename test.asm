.include "constants.inc"
.include "header.inc"

; .proc allows us to create new lexical scopes. A label 'some_label' in .proc foo
; is not the same as 'some_label' in .proc bar. You can only access foo's some_label
; from foo. Useful for wrapping independent pieces of code in their own procs, so
; you can use the same label names without messing with the others.

; The IRQ is the 'interrupt request' vector, which can be triggered by the NES'
; sound processor or from certain types of cartridge hardware.
.segment "CODE"
.proc irq_handler
  RTI
.endproc

; The NMI is the 'Non-Maskable Interrupt' vector, which occurs when the PPU starts
; preparing the next frame of graphics, 60 times per second.
.proc nmi_handler
  RTI
.endproc

; The reset vector occurs when the system is first turned on, or when the user
; presses the Reset button on the front of the console.
.proc reset_handler
  ; SEI is 'Set Interrupt ignor bit'. The system has finished setting up, so we
  ; don't want any interrupts.
  SEI
  ; CLD is 'clear decimal mode bit', disabling binary-coded decimal mode for the
  ; 6502.
  CLD
  LDX #00
  STX PPUCTRL ; PPUCTRL, much more complicated than PPUMASK, will be covered later.
  STX PPUMASK ; PPUMASK, which is covered later in main
vblankwait:
  ; vblankwait waits for the PPU to fully boot up before moving to our main code.
  BIT PPUSTATUS
  BPL vblankwait
  JMP main
.endproc

.proc main

  ; $2002 is a read only MMIO (memory-mapped I/O) address, known as PPUSTATUS.
  ; When loading from $2002, the resulting byte gives you info about what the PPU
  ; is currently doing, as well as resetting the address latch for PPUADDR.
  ; In short, it makes sure that writes happen properly.
  LDX $2002

  ; Color palette assigning happens starting from 3f00. The NES could handle 8
  ; palettes of 4 colors each, 4 foreground and 4 background. The first color
  ; of each palette would be treated as the transparent/background color.
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  ; $2006 lets you store the PPU memory you want to address, $2007 is the value
  ; you want to set at said address. $2006 requires two stores, the high (left)
  ; byte, and the low (right) byte. So we selected address 3f00 in the previous
  ; two STX's, and now we're storing the value 28 into that address. This is the
  ; first color of the first palette, which sets the background color to color 28
  ; out of the 64 colors the NES can display.
  LDA #$28
  STA PPUDATA

  ; $2001 is also known as PPUMASK, and this is a set of 8 bit flags, to tell the PPU
  ; to display things to the screen. Each bit in the byte acts as an on/off switch
  ; for a particular property. For the documentation, visit: https://famicom.party/book/05-6502assembly/
  LDA #%00011110
  STA PPUMASK

  ; this next part sets the program to loop infinitely. If this wasn't the case,
  ; it would try to move on in memory and start accessing random elements, which
  ; would cause a problem.
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"
.res 8192
.segment "STARTUP"
