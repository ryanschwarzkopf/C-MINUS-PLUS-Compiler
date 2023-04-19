### Lab21 CS 370
### First time using Lex and Yacc together
### Jan 27, 2023
### Ryan Schwarzkopf

# dependencies: lab22.l lab22.y
# description: makefile runs yacc and then lex and compiles the result into lab22 executable

all: lab22

lab22: lab22.l lab22.y
	yacc -d lab22.y
	lex lab22.l
	gcc y.tab.c -o lab22

clean:
	rm -f lab22
	rm -f y.tab.c
	rm -f y.tab.h
	rm -f lex.yy.c	
