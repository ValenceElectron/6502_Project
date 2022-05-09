.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00          ; Loads 00 literal into A
  STA OAMADDR       ; Writes A into OAMADDR, which tells the PPU to prepare for transfer into OAM starting at byte 00.
  LDA #$02          ; Loads 02 litearl into A
  STA OAMDMA        ; Writes A into OAMDMA, which tells the PPU to initiate high speed transfer of 256 bytes from $0200-$02ff into OAM
  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDX PPUSTATUS ; Refresh the latch to make sure we don't mess up any rendering.

  ; Point to the starting address for our palettes.
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  ; Actually select the palettes
  LDA #$29
  STA PPUDATA
  LDA #$19
  STA PPUDATA
  LDA #$09
  STA PPUDATA
  LDA #$0f
  STA PPUDATA

  ; Write the sprite data
  LDA #$70
  STA $0200   ; Y-coord of first sprite
  LDA #$05
  STA $0201   ; tile number of first sprite
  LDA #$00
  STA $0202   ; attributes of first sprite
  LDA #$80
  STA $0203   ; X-coord of first sprite

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK
  
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"
