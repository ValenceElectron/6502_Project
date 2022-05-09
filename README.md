# 6502_Project
A personal project to work on software for the 6502 processor, which came out in 1975. In particular, I'll be trying to write software for the NES.

# Assembling and Linking
To assemble .asm files:
`ca65 test.asm`

To link the resultant .o file into a .nes:
`ld65 test.o -t nes -o test.nes`
