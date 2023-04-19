### Lab5 CS 370
### CMINUS+ into YACC and LEX
### Feb 25, 2023
### Ryan Schwarzkopf

# dependencies: lab5.l lab5.y
# description: Makefile runs lex and then yacc and compiles results into executable.

all: lab5

lab5: lab5.l lab5.y
	lex lab5.l
	yacc -d lab5.y
	gcc lex.yy.c y.tab.h y.tab.c -o lab5

clean:
	rm -f lex.yy.c
	rm -f y.tab.h
	rm -f y.tab.c
	rm -f lab5
