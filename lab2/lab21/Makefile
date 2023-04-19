### Lab21 CS 370
### Reinforce Lex usage and the use of user defined variables.
### Jan 27, 2023
### Ryan Schwarzkopf

# dependencies: lab2remove.l
# description: Makefile runs lex and then compiles the result giving lab21 executable

all: lab21

lab21: lab21.l
	lex lab21.l
	gcc lex.yy.c -o lab21

clean:
	rm -f lab21
	rm -f lex.yy.c
