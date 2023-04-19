/*
			Lex tokens: T_INT, T_VOID, T_IF, T_ELSE, T_WHILE, T_RETURN, T_READ, T_WRITE, T_LE, T_LT,
				    T_GE, T_GT, T_EQ, T_NE, T_STRING, T_NUM, T_ADD, T_MINUS, T_MUL, T_DIV, T_ID, T_MOD
			Lex is the companion to lab6.y YACC routine which reads C-MINUS+ programs. Lex still
			counts new lines and will eat any C-MINUS+ comments started by "//". Setting mydebug
			to 1 will print to console the tokens lex returns.
			Ryan Schwarzkopf
			Apr 14, 2023
*/
%{

int mydebug = 0;
int lineno = 1;
#include "ast.h"
#include "y.tab.h"

%}


%%

int			{ if(mydebug) fprintf(stderr,"return token T_INT\n"); 
				return(T_INT); }
void			{ if(mydebug) fprintf(stderr,"return token T_VOID\n");
				return(T_VOID); }
if			{ if(mydebug) fprintf(stderr,"return token T_IF\n");
				return(T_IF); }
else			{ if(mydebug) fprintf(stderr,"return token T_ELSE\n");
				return(T_ELSE); }
while			{ if(mydebug) fprintf(stderr,"return token T_WHILE\n");
				return(T_WHILE); }
return			{ if(mydebug) fprintf(stderr,"return token T_RETURN\n");
				return(T_RETURN); }
read			{ if(mydebug) fprintf(stderr,"return token T_READ\n");
				return(T_READ); }
write			{ if(mydebug) fprintf(stderr,"return token T_WRITE\n");
				return(T_WRITE); }
"<="			{ if(mydebug) fprintf(stderr,"return token T_LE\n");
				return(T_LE); }
"<"			{ if(mydebug) fprintf(stderr,"return token T_LT\n");
				return(T_LT); }
">="			{ if(mydebug) fprintf(stderr,"return token T_GE\n");
				return(T_GE); }
">"			{ if(mydebug) fprintf(stderr,"return token T_GT\n");
				return(T_GT); }
"=="			{ if(mydebug) fprintf(stderr,"return token T_EQUAL\n");
				return(T_EQ); }
"!="			{ if(mydebug) fprintf(stderr,"return token T_NOTEQUAL\n");
				return(T_NE); }
"+"			{ if(mydebug) fprintf(stderr,"return token T_ADD\n");
				return(T_ADD); }
"-"			{ if(mydebug) fprintf(stderr,"return token T_MINUS\n");
				return(T_MINUS); }
"*"			{ if(mydebug) fprintf(stderr,"return token T_MUL\n");
				return(T_MUL); }
"/"			{ if(mydebug) fprintf(stderr,"return token T_DIV\n");
				return(T_DIV); }
"%"			{ if(mydebug) fprintf(stderr,"return token T_MOD\n");
				return(T_MOD); }
\".*\"			{ if(mydebug) fprintf(stderr,"return token T_STRING\n"); // Read a string: double quotes surrounding a number of characters.
				yylval.string=strdup(yytext); return(T_STRING); }
[a-zA-Z][a-zA-Z0-9_]*	{ if (mydebug) fprintf(stderr,"return token T_ID\n"); // Read a variable: Must start with a letter and can have any letters, numbers, or '_'
                       		yylval.string=strdup(yytext); return(T_ID); }
[0-9][0-9]*		{ if (mydebug) fprintf(stderr,"return token T_NUM\n"); // Read an integer: 1 or more numbers.
                       		yylval.value=atoi((const char *)yytext); return(T_NUM); }
[ \t]			{ if (mydebug) fprintf(stderr,"whitespace found\n"); } // Read whitespace
[;=(),\[\]{}]	{ if (mydebug) fprintf(stderr,"return a token %c\n",*yytext); // Read single character token.
                       		return (*yytext); }
\n			{ lineno++;
			  if (mydebug) fprintf(stderr,"carriage return %c\n",*yytext); } // Increment for newline.
\/\/.*			{ if(mydebug) fprintf(stderr,"comment Found\n"); /* Comments are eaten by lex */ } 

%%

int yywrap(void)
{ return 1; }
