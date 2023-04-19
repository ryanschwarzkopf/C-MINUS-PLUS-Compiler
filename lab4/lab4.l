/*                 Small LEX routine which returns two formal tokens (INTEGER and VARIABLE)
                   along with single string elements like '+'.
 
                    This LEX definition is the companion to the docalc.y YACC routine which
                   is a simple calculator

                    Shaun Cooper
                    January 2015
*/
/*
		   Added parenthesis to single string elements list.
		   Ryan Schwarzkopf
		   Jan 27, 2023
*/
/*
			Lex reads in newlines and counts them with lineno. Lex reads in semicolon as a token and int as a token.
			Lex can read in variables and return VARIABLE token with companion value.
			yylav is given a type string or type value
			Ryan Schwarzkopf
			Feb 22, 2023
*/
%{

int mydebug = 0;
int lineno = 0;
#include "y.tab.h"
%}


%%

int			{ if(mydebug) fprintf(stderr,"return token T_INT\n"); 
				return(T_INT); }
[a-zA-Z][a-zA-Z0-9_]*	{ if (mydebug) fprintf(stderr,"Variable found\n"); 
                       		yylval.string=strdup(yytext); return(VARIABLE); }
[0-9][0-9]*		{ if (mydebug) fprintf(stderr,"Digit found\n"); 
                       		yylval.value=atoi((const char *)yytext); return(INTEGER); }
[ \t]			{ if (mydebug) fprintf(stderr,"Whitespace found\n"); }
[;=\-+*/%&|()] 		{ if (mydebug) fprintf(stderr,"return a token %c\n",*yytext); 
                       		return (*yytext); }
\n 			{ lineno++;
			  if (mydebug) fprintf(stderr,"carriage return %c\n",*yytext); 
                       		return (*yytext); }

%%

int yywrap(void)
{ return 1;}
