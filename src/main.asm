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
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$0f
  BNE load_palettes

  ; Write the sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$0f
  BNE load_sprites

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

.segment "RODATA"
palettes:
.byte $0d, $21, $11, $01, $0d, $26, $16, $0d, $09, $24, $14, $04, $0d, $29, $19, $09
sprites:
.byte $70, $05, $00, $80, $70, $06, $00, $88, $78, $07, $00, $80, $78, $08, $00, $88

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"
