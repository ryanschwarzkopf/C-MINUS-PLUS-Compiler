/* 
	Symbol Table
	Lab 3 CS_370
	Ryan Schwarzkopf Feb 3, 2023
	Original code was pulled from https://nmsu.instructure.com/courses/1524542/assignments/13188993.
	I formatted and commented the original code. I moved all function and struct definitions and also all header files into a file symtable.h.
	I took off all occurrences and functionality of "label". Main now collects all information for functions: INSERT, DISPLAY, DELETE, SEARCH.
	I removed MODIFY and its functionality in main(). I added functionality to eat all the newlines in the input stream.
	I included fileguards to the symtable header file
*/
/*
	Symtable will only print to console on Display() or if mydebug is turned to 1. Fetchaddr searches for a symbol and returns the address.
	mydebug is extern variable.
	Insert() no longer checks for max. (commented out).
	Symtable no longer has a main function. (commented out).
	Feb 22, 2023
	Ryan Schwarzkopf
*/
#include"symtable.h"

int size=0;
extern int mydebug;
struct SymbTab *first, *last;

/*
	Main function
	PRE no input to main
	POST main program asks for input and manages a list of symbols
*/
/*
int main(void) {
	int op;
	char *symbol;
	char sym[100];
	int address;
	// Query loop: to get an operation from the user. 5 to exit the loop
	do {
		printf("\n\tSYMBOL TABLE IMPLEMENTATION\n");
		printf("\n\t1.INSERT\n\t2.DISPLAY\n\t3.DELETE\n\t4.SEARCH\n\t5.END\n");
		printf("\n\tEnter your option : ");
		scanf("%d",&op);
		switch(op) {
			case 1: // ---Insert---
				printf("\n\tEnter the symbol : ");
				scanf("%s",sym);
				printf("\n\tEnter the address : ");
				scanf("%d",&address);
				symbol = sym;
				Insert(symbol, address);
				break;
			case 2: // ---Display---
				Display();
				break;
			case 3: // ---Delete---
				printf("\n\tEnter the symbol to be deleted : ");
				scanf("%s",sym);
				symbol = sym;
				Delete(symbol);
				break;
			case 4: // ---Search---
				printf("\n\tEnter the symbol to be searched : ");
				scanf("%s",sym);
				symbol = sym;
				printf("\n\tSearch Result:");
				if(Search(symbol) == NULL) printf("\n\tThe symbol is not present in the symbol table\n");
				else printf("\n\tThe symbol is present in the symbol table\n");
				break;
			case 5: // ---End---
				break;
			default:
				printf("option %d not implemented, try again\n",op);
				break;
		} // end switch
	} while(op<5); // end while
}  // end of main
*/

/*
 * FetchAddr searches for symbol and returns address if found. Returns -1 if not found.
 * PRE: We assume that symbol has already been searched for and exists in the symbol table.
 * POST: return the address of the sybmol
 */
int FetchAddr(char *sym) {
	struct SymbTab *p;
	p = NULL;
	p = Search(sym);
	if(p == NULL) return -1;
	return p->addr;
}

/*
	Insert function is a modification method. Put into list if not found else return NULL.
	EDIT: max is checked in yacc. Commented out the max check.
	PRE: PTR to character string symbol, address of new symbol
	POST: New symbol has been added to structure, size increments. Returns PTR to new symbol.
*/
struct SymbTab* Insert(char *symbol, int address) {
	/*
	if(size == max) {
		if(mydebug) printf("\n\t Symbol table is full.");
		return NULL;
	}
	*/
	if(Search(symbol) != NULL) { // check if symbol exists. If yes return null
		if(mydebug) printf("\n\tThe symbol exists already in the symbol table\n\tDuplicate can't be inserted");
		return NULL;
	}
	// no symbol found so add it to list
	struct SymbTab *p;
	p=malloc(sizeof(struct SymbTab));
	p->symbol = strdup(symbol);
	p->addr = address;
	p->next=NULL;
	if(size==0) { // list is empty so first=last=p
		first=p;
		last=p;
	} else { // list isnt empty so p is last
		last->next=p;
		last=p;
	}
	size++;
	if(mydebug) printf("\n\tSymbol inserted\n");
	return p;
} // end Insert

/*
	Display Function prints the list.
	PRE depends on first Symtable node
	POST Prints out list. Does not modify. 
*/
void Display() {
	int i;
	struct SymbTab *p;
	p=first;
	printf("\t\tSYMBOL\t\tADDRESS\n");
	for(i=0;i<size;i++) { // print symbols/addresses one at a time. Move down list
		printf("\t%s\t\t%d\n",p->symbol,p->addr);
		p=p->next;
	} // end for
} // end Display

/*
	Search Function
	PRE PTR to character string: Symbol to be searched for.
	POST PTR to symbol if found, NULL if not found
*/
struct SymbTab* Search(char *symbol) {
	int i;
	struct SymbTab *p;
	p=first;
	for(i=0;i<size;i++) { // move down list, return if found
		if(strcmp(p->symbol,symbol)==0) return p;
		p=p->next;
	}
	return NULL;
} // end Search

/*
	Delete Function
	PRE PTR to character string, symbol to be deleted
	POST struct with symbol has been deleted. Size decrements
*/
void Delete(char *symbol) {
	if(Search(symbol) == NULL) { // check if symbol exists
		if(mydebug) printf("\n\tSymbol not found\n");
		return;
	}
	struct SymbTab *p,*q;
	p=first;
	if(strcmp(first->symbol,symbol)==0)
		first=first->next;
	else if(strcmp(last->symbol,symbol)==0) {
		q=p->next;
		while(strcmp(q->symbol,symbol)!=0) {
			p=p->next;
			q=q->next;
		}
	p->next=NULL;
	last=p;
	}
	else {
		q=p->next;
		while(strcmp(q->symbol,symbol)!=0) {
			p=p->next;
			q=q->next;
		}
		p->next=q->next;
	}
	size--;
	if(mydebug) printf("\n\tAfter Deletion:\n");
	Display();
} // end Delete
