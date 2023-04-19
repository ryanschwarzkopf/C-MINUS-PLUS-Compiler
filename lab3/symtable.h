//Symbol table header file
//Ryan Schwarzkopf
//CS_370 lab3
//Feb 3, 2023


#ifndef SYMTABLE_H
#define SYMTABLE_H

#include<stdio.h>
/* #include<conio.h> */
#include<malloc.h>
#include<string.h>
#include<stdlib.h>

struct SymbTab {
	char *symbol;
	int addr;
	struct SymbTab *next;
};

struct SymbTab * Insert(char *symbol, int address);
void Display();
void Delete();
struct SymbTab * Search(char *symbol);

#endif
