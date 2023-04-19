### Lab4 CS 370
### Symbol Table with YACC
### Feb 10, 2023
### Ryan Schwarzkopf

# dependencies: lab4.l lab4.y symtable.c symtable.h
# description: Makefile runs lex and then yacc and compiles the result with symtable into lab4 executable

all: lab4

lab4: lab4.l lab4.y symtable.c symtable.h
	lex lab4.l
	yacc -d lab4.y
	gcc lex.yy.c y.tab.c symtable.c -o lab4

clean:
	rm -f lab4
	rm -f y.tab.c
	rm -f y.tab.h
	rm -f lex.yy.c