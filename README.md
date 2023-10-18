# 6502_Project
A personal project to work on software for the NES' 6502 processor. Learning via https://famicom.party/book/

# Assembling and Linking
`ca65 src/main.asm && ca65 src/reset.asm`  <br />
`ld65 src/reset.o src/main.o -C nes.cfg -o game.nes`  <br />
