%{

/*
 *			**** CALC ****
 *
 * This routine will function like a desk calculator
 * There are 26 integer registers, named 'a' thru 'z'
 *
 */

/* This calculator depends on a LEX description which outputs either VARIABLE or INTEGER.
   The return type via yylval is integer 

   When we need to make yylval more complicated, we need to define a pointer type for yylval 
   and to instruct YACC to use a new type so that we can pass back better values
 
   The registers are based on 0, so we substract 'a' from each single letter we get.

   based on context, we have YACC do the correct memmory look up or the storage depending
   on position

   Shaun Cooper
    January 2015

   problems  fix unary minus, fix parenthesis, add multiplication
   problems  make it so that verbose is on and off with an input argument instead of compiled in
*/
/*
	Added functionality for multiplication of expressions. Added int return type to main().
	Add space after "answer is" for readability. Added parenthesis to precedence list.
	Removed left hand 'expr' because unary minus does not require a left hand expression.
	Ryan Schwarzkopf
	Jan 27, 2023
*/
/*
	Removed #include lex.yy.c. Add extern int lineno, and size, for # of current variables.
	const MAX is the max number of variables allowed. Added token VARIABLE Union struct gives types to the tokens.
	Syntax directed sematic action added for variable declaration, definition, and reference of variables.
	Deleted variables debugsw and base.
	Ryan Schwarzkopf
	Feb 22, 2023
*/

	/* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "symtable.h"

int yylex();

extern int lineno;
extern int mydebug;
extern int size;

// MAX is maximum number of variables allowed
#define MAX 2
#define INTMAX 2147483647
int regs[MAX] = { INTMAX };

void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s line number: %d\n", s,lineno);
}


%}
/*  defines the start symbol, what values come back from LEX and how the operators are associated  */

%union 
{
	int value;
	char *string;
}

%start P

%token <value> INTEGER
%token <string> VARIABLE
%token T_INT
%type <value> expr stat

%left '(' ')'
%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS


%%	/* end specs, begin rules */
P	:	DECLS list
  	;

DECLS	:	DECLS DECL
	|	/* empty */
	;

DECL	:	T_INT VARIABLE ';' '\n' 
				{	
					if(Search($2) == NULL) {
						if(size < MAX) {
							Insert($2, size);
						} else {
							printf("Max number of variables reached.\n");
						}
					} else {
						printf("Variable already defined.\n");
					}
				}
	;

list	:	/* empty */
	|	list stat '\n'
	|	list error '\n'
			{ yyerrok; }
	;

stat	:	expr
			{ fprintf(stderr,"the anwser is %d\n", $1); }
	|	VARIABLE '=' expr
			{	
				if(Search($1) != NULL) {
					regs[FetchAddr($1)] = $3; 
				} else {
					printf("Variable not declared.\n");
				}
			}
	;

expr	:	'(' expr ')'
			{ $$ = $2; }
	|	expr '-' expr
			{ $$ = $1 - $3; }
	|	expr '+' expr
			{ $$ = $1 + $3; }
	|	expr '*' expr
			{ $$ = $1 * $3; }
	|	expr '/' expr
			{ $$ = $1 / $3; }
	|	expr '%' expr
			{ $$ = $1 % $3; }
	|	expr '&' expr
			{ $$ = $1 & $3; }
	|	expr '|' expr
			{ $$ = $1 | $3; }
	|	'-' expr	%prec UMINUS
			{ $$ = -$2; }
	|	VARIABLE
			{
				if(Search($1) != NULL) {
					if(regs[FetchAddr($1)] != INTMAX) {
						$$ = regs[FetchAddr($1)];
					} else {
						printf("Variable has not been defined.\n");
						$$ = 0;
					}
				} else {
					printf("Variable is not in symbol table.\n");
					$$ = 0;
				}
				if(mydebug) fprintf(stderr,"found a variable value =%s\n",$1);
			}
	|	INTEGER 
			{
			  $$=$1;
			  if(mydebug) fprintf(stderr,"found an integer\n");
			}
	;



%%	/* end of rules, start of program */

int main()
{ yyparse();
}
