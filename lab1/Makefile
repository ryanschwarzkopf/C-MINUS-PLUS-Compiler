### Lab1 CS 370
### Simple word and number 
### Jan 20, 2023
### Ryan Schwarzkopf

# dependencies: lab1.l
# makefile runs lex and then compiles the result giving lab1 executable

all: lab1

lab1: lab1.l
	lex lab1.l
	gcc lex.yy.c -o lab1

clean:
	rm -f lab1
