%{

/*
	YACC implements the C-MINUS+ extended BNF grammer. 
	Running yacc on this file produces one shift/reduce conflict.
	The start symbol for yacc is Program. Yacc only checks if the token sequence is correct.
	Yacc uses sytax directed semantic action with ast.c to produce an abstract syntax tree.
	Ryan Schwarzkopf
	Mar 29, 2023
*\
	/* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "ast.h"

ASTnode *PROGRAM = NULL;

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

/* token types */
%union 
{
	int value;
	char *string;
	ASTnode *node;
	enum AST_MY_DATA_TYPE input_type;
	enum AST_OPERATORS operator;
}

%start Program

%token<value> T_NUM
%token<string> T_ID T_STRING
%token T_INT T_VOID T_IF T_ELSE T_WHILE T_RETURN T_READ T_WRITE
%token T_LT T_LE T_GT T_GE T_EQ T_NE T_ADD T_MINUS T_MUL T_DIV T_MOD
%type<node> Fun_Declaration Var_List Var_Declaration Declaration Declaration_List
%type<node> Params Compound_Statement Local_Declarations Statement_List
%type<node> Statement Write_Statement Expression Simple_Expression 
%type<node> Additive_Expression Term Factor Read_Statement Expression_Statement
%type<node> Var Return_Statement Call Arg_List Args Assignment_Statement
%type<node> Iteration_Statement Selection_Statement Param Param_List
%type<input_type> Type_Specifier
%type<operator> Addop Relop Multop

%%	/* end specs, begin rules */

Program			:	Declaration_List { PROGRAM = $1; }
  			;

Declaration_List	:	Declaration { $$ = $1; }
		 	|	Declaration Declaration_List
				{ // Declarations are next connected: Variable, Function
					$$ = $1;
					$$->next = $2;
				}
			;

Declaration		:	Var_Declaration { $$ =$1; }
	     		|	Fun_Declaration { $$ = $1; }
	     		;

Var_Declaration		:	Type_Specifier Var_List ';'
				{ // add type to all variables in the list: int, void
					ASTnode *p;
					p = $2;
					while(p != NULL) {
						p->my_data_type = $1;
						p = p->s1;
					}
					$$ = $2;
				}
			;

Var_List 		:	T_ID /* Make a node for all variables in list. Attach Var-Dec names/values */ 
				{ 
					$$=ASTCreateNode(A_VARDEC);
					$$->name = $1;
				}
			|	T_ID '[' T_NUM ']'
				{
					$$=ASTCreateNode(A_VARDEC);
					$$->name = $1;
					$$->value = $3;
				}
	  		|	T_ID ',' Var_List
				{ // Variables in list are s1 connected
					$$=ASTCreateNode(A_VARDEC);
					$$->name = $1;
					$$->s1 = $3;
				}
			|	T_ID '[' T_NUM ']' ',' Var_List
				{ // Variables in list are s1 connected
					$$=ASTCreateNode(A_VARDEC);
					$$->name = $1;
					$$->value = $3;
					$$->s1 = $6;
				}
			;

Type_Specifier		:	T_INT { $$ = A_INTTYPE; }
			|	T_VOID { $$ = A_VOIDTYPE; }
			;

Fun_Declaration 	:	Type_Specifier T_ID '(' Params ')' Compound_Statement
		 		{ // Make a new node that holds name & datatype, node points to parameter list or void, and function body
					$$ = ASTCreateNode(A_FUNCTIONDEC);
					$$->name = $2;
					$$->my_data_type = $1;
					$$->s1 = $4;
					$$->s2 = $6;
				}
			;

Param			:	Type_Specifier T_ID
				{ // New node for each parameter, set name/datatype, and value of 1 to identify an array
					$$ = ASTCreateNode(A_PARAM);
					$$->name = $2;
					$$->my_data_type = $1;
				}
			|	Type_Specifier T_ID '[' ']'
				{
					$$ = ASTCreateNode(A_PARAM);
					$$->name = $2;
					$$->my_data_type = $1;
					$$->value = 1;
				}
			;

Params			:	T_VOID
	 			{ // VOID for no parameter list
					$$ = NULL;
				}
	 		|	Param_List
				{
					$$ = $1;
				}
			;

Param_List		:	Param { $$ = $1; }
	    		|	Param ',' Param_List 
				{ // Parameters are next connected
					$$ = $1;
					$$->next = $3;
				}
	    		;

Compound_Statement	:	'{' Local_Declarations Statement_List '}'
				{ // Compound statement is the body of a function. Points to a list of declarations and a list of statements
					$$ = ASTCreateNode(A_COMPOUND);
					$$->s1 = $2;
					$$->s2 = $3;
				}
			;

Local_Declarations	:	Var_Declaration Local_Declarations
		   		{ // Declarations are next connected
					$$ = $1;
					$$->next = $2;
				}
		   	|	/* empty */ { $$ = NULL; }
			;

Statement_List		:	Statement Statement_List
				{ // Statements are next connected
					$$ = $1;
					$$->next = $2;
				}
			|	/* empty */ { $$ = NULL; }
			;

Statement		:	Expression_Statement { $$ = $1; } // Every type of statement gets a node
	   		|	Compound_Statement { $$ = $1; }
			|	Selection_Statement { $$ = $1; }
			|	Iteration_Statement { $$ = $1; }
			|	Assignment_Statement { $$ = $1; }
			|	Return_Statement { $$ = $1; }
			|	Read_Statement { $$ = $1; }
			|	Write_Statement { $$ = $1; }
			;

Expression_Statement	:	Expression ';' 
		     		{
					$$ = ASTCreateNode(A_EXSTAT);
					$$->s1 = $1;
				}
		     	|	';' 
				{
					$$ = ASTCreateNode(A_EXSTAT);
				}
			;

Selection_Statement	:	T_IF '(' Expression ')' Statement
		    		/* In the case there is an else, make two nodes for consistency
				   Make two nodes to point to an expression and possibly 2 statements
				   S1 always points to an expression. S2 always points to a new node.
				   S2->S1 always points to the If body. S2->S2 is either null (no else)
				   or points to the else body.  */
				{
					$$ = ASTCreateNode(A_IF);
					$$->s1 = $3;
					$$->s2 = ASTCreateNode(A_IF);
					$$->s2->s1 = $5;
				}
		    	|	T_IF '(' Expression ')' Statement  T_ELSE Statement
				{
					$$ = ASTCreateNode(A_IF);
					$$->s1 = $3;
					$$->s2 = ASTCreateNode(A_IF);
					$$->s2->s1 = $5;
					$$->s2->s2 = $7;
				}
		    	;

Iteration_Statement	:	T_WHILE '(' Expression ')' Statement
		    		{ // points to expression and statement
					$$ = ASTCreateNode(A_WHILE);
					$$->s1 = $3;
					$$->s2 = $5;
				}
			;

Return_Statement	:	T_RETURN ';'
		 		{ // no expression. returns void
					$$ = ASTCreateNode(A_RETURN);
				}
		 	|	T_RETURN Expression ';'
				{ // points to an expression
					$$ = ASTCreateNode(A_RETURN);
					$$->s1 = $2;
				}
			;

Read_Statement		:	T_READ Var ';'
				{ // points to variable to be read from
					$$ = ASTCreateNode(A_READ);
					$$->s1 = $2;
				}
			;

Write_Statement		:	T_WRITE T_STRING ';'
		 		{ // write holds a string to write
					$$ = ASTCreateNode(A_WRITE);
					$$->name = $2;
				}
		 	|	T_WRITE Expression ';'
				{ // write points to expression to write
					$$ = ASTCreateNode(A_WRITE);
					$$->s1 = $2;
				}
			;

Assignment_Statement	:	Var '=' Simple_Expression ';'
		     		{ // assignment points to a variable and a simple expression
					$$ = ASTCreateNode(A_ASSIGNMENT);
					$$->s1 = $1;
					$$->s2 = $3;
				}
		     	;

Var			:	T_ID
      				{ // Variable holds variable name
					$$ = ASTCreateNode(A_VAR);
					$$->name = $1;
				}
      			|	T_ID '[' Expression ']' 
				{ // Variable holds variable name, points to an expression for the array
					$$ = ASTCreateNode(A_VAR);
					$$->name = $1;
					$$->s1 = $3;
				}
			;

Expression		:	Simple_Expression { $$ = $1; }
	    		;

Simple_Expression	:	Additive_Expression { $$ = $1; } // No relop, go to additive to look for addop
		 	|	Simple_Expression Relop Additive_Expression 
				{ // Fourth on order precedence hierarchy, sets operator to RELOP, points to expressions on boths sides of RELOP
					$$ = ASTCreateNode(A_EXPR);
					$$->operator = $2;
					$$->s1 = $1;
					$$->s2 = $3;
				}
			;

Relop			:	T_LE		{ $$ = A_LE; } 
			|	T_LT		{ $$ = A_LT; }
			|	T_GT		{ $$ = A_GT; }
			|	T_GE		{ $$ = A_GE; }
			|	T_EQ		{ $$ = A_EQ; }
			|	T_NE		{ $$ = A_NE; }
			;

Additive_Expression	:	Term { $$ =$1; } // No addop, go to Term for multop
		    	|	Additive_Expression Addop Term
				{ // Third on hierarchy, sets addop, points to expressions on both sides of addop
					$$ = ASTCreateNode(A_EXPR);
					$$->operator = $2;
					$$->s1 = $1;
					$$->s2 = $3; 
				}
			;

Addop			:	T_ADD 		{ $$ = A_PLUS; }
			|	T_MINUS		{ $$ = A_MINUS; }
			;

Term			:	Factor { $$ = $1; } // No multop, go to factor
       			|	Term Multop Factor
				{ // Second on hierarchy, sets multop, points to expressions on both sides of multop
					$$ = ASTCreateNode(A_EXPR);
					$$->operator = $2;
					$$->s1 = $1;
					$$->s2 = $3;
				} 
			;

Multop			:	T_MUL { $$ = A_MUL; }
	 		|	T_DIV { $$ = A_DIV; }
			|	T_MOD { $$ = A_MOD; }
			;

Factor			:	'(' Expression ')' { $$ = $2; } /* Factor is top of operator precedence hierarchy */
	 		|	T_NUM
				{
					$$ = ASTCreateNode(A_NUM);
					$$->value = $1;
				}
			|	Var			{ $$ = $1; }
			|	Call			{ $$ = $1;}
			|	T_MINUS Factor	
				{
					$$ = ASTCreateNode(A_EXPR);
					$$->operator = A_UMINUS;
					$$->s1 = $2;
				}
			;

Call			:	T_ID '(' Args ')'
       				{ // point to variable, and arg list or null
					$$ = ASTCreateNode(A_CALL);
					$$->name = $1;
					$$->s1 = $3;
				}
       			;

Args			:	Arg_List { $$ = $1; }
       			|	/* empty */ { $$ = NULL; }
			;

Arg_List		:	Expression 
	  			{ // arg list points to expression(s), next connected
					$$ = ASTCreateNode(A_ARG);
					$$->s1 = $1;
				}
	  		|	Expression ',' Arg_List
				{
					$$ = ASTCreateNode(A_ARG);
					$$->s1 = $1;
					$$->next = $3;
				}
			;



%%	/* end of rules, start of program */

int main()
{ 
	yyparse();
	printf("\nFinished Parsing\n\n\n");
	ASTprint(0,PROGRAM);
	return 0;
}
