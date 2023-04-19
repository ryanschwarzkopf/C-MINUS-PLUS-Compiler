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
/*
	Removed calculator functionality. YACC implements the C-MINUS+ extended BNF grammer. 
	Running yacc on this file produces one shift/reduce conflict. Yacc prints companion value of T_ID to console.
	when found. Start symbol for yacc is Program.
	Ryan Schwarzkopf
	Feb 24, 2023
*\
	/* begin specs */
#include <stdio.h>
#include <ctype.h>

int yylex();

extern int lineno;
extern int mydebug;

void yyerror (s)  /* Called by yyparse on error */ /* Prints line number of the error. */
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

%start Program

%token<value> T_NUM
%token<string> T_ID
%token T_INT
%token T_VOID
%token T_STRING
%token T_IF
%token T_ELSE
%token T_WHILE
%token T_RETURN
%token T_READ
%token T_WRITE
%token T_LT
%token T_LE
%token T_GT
%token T_GE
%token T_EQ
%token T_NE
%token T_ADD
%token T_MINUS
%token T_MUL
%token T_DIV
	
%%	/* end specs, begin rules */
Program			:	Declaration_List
  			;

Declaration_List	:	Declaration
		 	|	Declaration Declaration_List
			;

Declaration		:	Var_Declaration
	     		|	Fun_Declaration
	     		;

Var_Declaration		:	Type_Specifier Var_List ';'
			;

Var_List		:	T_ID 								{ printf("Var_LIST with value %s\n", $1); }
	  		|	T_ID '[' T_NUM ']' 						{ printf("Var_LIST with value %s\n", $1); }
	  		|	T_ID ',' Var_List 						{ printf("Var_LIST with value %s\n", $1); }
			|	T_ID '[' T_NUM ']' ',' Var_List 				{ printf("Var_LIST with value %s\n", $1); }
			;

Type_Specifier		:	T_INT
			|	T_VOID
			;

Fun_Declaration 	:	Type_Specifier T_ID '(' Params ')' Compound_Statement 		{ printf("FunDec with value %s\n", $2); }
		 	;

Param			:	Type_Specifier T_ID						{ printf("PARAM with value %s\n", $2); }
			|	Type_Specifier T_ID '[' ']'					{ printf("PARAM with value %s\n", $2); }
			;

Params			:	T_VOID
	 		|	Param_List
			;

Param_List		:	Param
	    		|	Param ',' Param_List
	    		;

Compound_Statement	:	'{' Local_Declarations Statement_List '}'
			;

Local_Declarations	:	Var_Declaration Local_Declarations
		   	|	/* empty */
			;

Statement_List		:	Statement Statement_List
			|	/* empty */
			;

Statement		:	Expression_Statement
	   		|	Compound_Statement
			|	Selection_Statement
			|	Iteration_Statement
			|	Assignment_Statement
			|	Return_Statement
			|	Read_Statement
			|	Write_Statement
			;

Expression_Statement	:	Expression ';'
		     	|	';'
			;

Selection_Statement	:	T_IF '(' Expression ')' Statement
		    	|	T_IF '(' Expression ')' Statement  T_ELSE Statement
		    	;

Iteration_Statement	:	T_WHILE '(' Expression ')' Statement
			;

Return_Statement	:	T_RETURN ';'
		 	|	T_RETURN Expression ';'
			;

Read_Statement		:	T_READ Var ';'
			;

Write_Statement		:	T_WRITE Expression ';'
		 	|	T_WRITE T_STRING ';'
			;

Assignment_Statement	:	Var '=' Simple_Expression ';'
		     	;

Var			:	T_ID								{ printf("Var with value %s\n", $1); }
      			|	T_ID '[' Expression ']'						{ printf("Var with value %s\n", $1); }
			;

Expression		:	Simple_Expression
	    		;

Simple_Expression	:	Additive_Expression
		 	|	Additive_Expression Relop Additive_Expression
			;

Relop			:	T_LE
			|	T_LT
			|	T_GT
			|	T_GE
			|	T_EQ
			|	T_NE
			;

Additive_Expression	:	Term
		    	|	Additive_Expression Addop Term
			;

Addop			:	T_ADD
			|	T_MINUS
			;

Term			:	Factor
       			|	Term Multop Factor
			;

Multop			:	T_MUL
	 		|	T_DIV
			;

Factor			:	'(' Expression ')'
	 		|	T_NUM
			|	Var
			|	Call
			|	T_MINUS Factor
			;

Call			:	T_ID '(' Args ')'						{ printf("CALL with value %s\n", $1); }
       			;

Args			:	Arg_List
       			|	/* empty */
			;

Arg_List		:	Expression
	  		|	Expression ',' Arg_List
			;



%%	/* end of rules, start of program */

int main()
{ yyparse();
}
