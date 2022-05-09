# 6502_Project
A personal project to work on software for the 6502 processor, which came out in 1975. In particular, I'll be trying to write software for the NES.

# Assembling and Linking
`ca65 src/main.asm`
`ca65 src/reset.asm`
`ld65 src/reset.o src/main.o -C nes.cfg -o game.nes`
