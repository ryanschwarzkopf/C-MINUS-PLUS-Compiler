### Lab6 CS 370
### CMINUS+ Abstract Syntax Tree
### Mar 29, 2023
### Ryan Schwarzkopf

# dependencies: lab6.l lab6.y ast.h ast.c
# description: Makefile runs lex and then yacc and compiles results with ast.c into executable.

all: lab6

lab6: lab6.l lab6.y ast.h ast.c
	lex lab6.l
	yacc -d lab6.y
	gcc lex.yy.c y.tab.c ast.c -o lab6

clean:
	rm -f lex.yy.c
	rm -f y.tab.h
	rm -f y.tab.c
	rm -f lab6
