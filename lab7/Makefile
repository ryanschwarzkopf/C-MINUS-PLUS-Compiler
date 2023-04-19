### Lab7 CS 370
### CMINUS+ Add Symbol Table and Type Checking
### April 14, 2023
### Ryan Schwarzkopf

# dependencies: lab7.l lab7.y ast.h ast.c symtable.h symtable.c
# description: Makefile runs lex and yacc and then compiles results together with ast.c and symtable.c for executable

all: lab7

lab7: lab7.l lab7.y ast.h ast.c symtable.h symtable.c
	lex lab7.l
	yacc -d lab7.y
	gcc lex.yy.c y.tab.c ast.c symtable.c -o lab7

clean:
	rm -f lex.yy.c
	rm -f y.tab.h
	rm -f y.tab.c
	rm -f lab7
