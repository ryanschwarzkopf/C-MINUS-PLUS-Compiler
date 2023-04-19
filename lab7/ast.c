/*   Abstract syntax tree code

     This code is used to define an AST node, 
    routine for printing out the AST
    defining an enumerated type so we can figure out what we need to
    do with this.  The ENUM is basically going to be every non-terminal
    and terminal in our language.

    Shaun Cooper Spring 2023

*/

#include<stdio.h>
#include<malloc.h>
#include "ast.h" 


/* uses malloc to create an ASTnode and passes back the heap address of the newley created node */
//  PRE:  Ast Node Type
//  POST:   PTR To heap memory and ASTnode set and all other pointers set to NULL
ASTnode *ASTCreateNode(enum ASTtype mytype) {
    ASTnode *p;
    if (mydebug) fprintf(stderr,"Creating AST Node \n");
    p=(ASTnode *)malloc(sizeof(ASTnode));
    p->type=mytype;
    p->s1=NULL;
    p->s2=NULL;
    p->next=NULL;
    p->value=0;
    return(p);
}

/*  Helper function to print tabbing */
//PRE:  Number of spaces desired
//POST:  Number of spaces printed on standard output

void PT(int howmany) {
	for(int i=0;i<howmany;i++) printf(" ");
}

//  PRE:  A declaration type
//  POST:  A character string that is the name of the type
//          Typically used in formatted printing
char * ASTtypeToString(enum AST_MY_DATA_TYPE mytype) {
    switch(mytype) {
      case A_INTTYPE:
        return "INT";
        break;
      case A_VOIDTYPE:
	return "VOID";
	break;
      default: 
        printf("ASTtypeToString UNKOWN type\n");
        return "UNKNOWN TYPE";
	break;
    }
}



/*  Print out the abstract syntax tree */
// PRE:   PRT to an ASTtree
// POST:  indented output using AST order printing with indentation

void ASTprint(int level, ASTnode *p) {
   int i;
   if (p == NULL ) return;
   switch (p->type) {
     case A_VARDEC :
       //print the name and type of the variable declaration
       // value will be set other than zero if it is an array type
       // print the current level and offset of the variable
       PT(level);
       printf("Variable %s %s", 
         ASTtypeToString(p->my_data_type),
         p->name);
       if(p->value != 0) printf(" [%d]", p->value);
       printf(" level %d offset %d",
         p->symbol->level,
	 p->symbol->offset);
       printf(" \n");
       ASTprint(level, p->s1);
       ASTprint(level, p->next);
       break;
     case A_FUNCTIONDEC :  
       // print the name, datatype, level, and offset of the function declaration
       PT(level); 
       printf("Function %s %s level %d offset %d",
         ASTtypeToString(p->my_data_type), 
	 p->name,
	 p->symbol->level,
	 p->symbol->offset); 
       printf(" \n");
       ASTprint(level+1, p->s1); // parameters
       ASTprint(level+1, p->s2); // compound
       ASTprint(level, p->next);
       break;
     case A_COMPOUND :
       PT(level); printf("Compound Statement \n");
       ASTprint(level+1, p->s1); // local decs
       ASTprint(level+1, p->s2); // statement list
       ASTprint(level, p->next);
       break;
     case A_WRITE :
       // write will either carry a string in name to be printed, or will point to an expression
       PT(level);
       if(p->name != NULL) {
         printf("Write String  %s \n", p->name);
       } else if(p->s1 != NULL) { // it is an expression
         printf("Write Expression \n");
	 ASTprint(level+1, p->s1);
       }
       ASTprint(level, p->next);
       break;
     case A_NUM :
       // print the value of the number found
       PT(level);
       printf("NUMBER value %d \n", p->value);  
       break;
     case A_EXPR :
       // print any expression operator
       PT(level);
       printf("EXPRESSION operator ");
       switch(p->operator) {
         case A_PLUS: printf("PLUS \n"); break;
	 case A_MINUS: printf("MINUS \n"); break;
	 case A_MUL: printf("TIMES \n"); break;
	 case A_DIV: printf("/ \n"); break;
	 case A_LE: printf("<= \n"); break;
	 case A_GE: printf(">= \n"); break;
	 case A_LT: printf("< \n"); break;
	 case A_GT: printf("> \n"); break;
	 case A_EQ: printf("== \n"); break;
	 case A_NE: printf("!= \n"); break;
	 case A_MOD: printf("% \n"); break;
	 case A_UMINUS: printf("Unary-minus \n"); break;
	 default: printf("unknown operator in A_EXPR in ASTprint \n"); break;
       } // end switch operator
       ASTprint(level+1, p->s1);
       ASTprint(level+1, p->s2);
       break;
     case A_READ:
       PT(level);
       printf("READ STATEMENT \n");
       ASTprint(level+1, p->s1);
       ASTprint(level, p->next);
       break;
     case A_VAR:
       // print variable name, if it is an array, print the index in brackets
       // print the level and offset of variable
       PT(level);
       if(p->name != NULL) printf("VARIABLE %s", p->name);
       if(p->s1 != NULL) {
	       printf(" \n");
	       PT(level+1);
	       printf("[ \n");
	       ASTprint(level+2, p->s1);
	       PT(level+1);
	       printf("]");
       }
       printf(" level %d offset %d", p->symbol->level, p->symbol->offset);
       printf(" \n");
       break;
     case A_RETURN:
       PT(level);
       printf("RETURN STATEMENT \n");
       ASTprint(level+1, p->s1);
       ASTprint(level, p->next);
       break;
     case A_CALL:
       // Print the name of function to be called
       // If there are arguments, print them, they will be next connected so all of them will print.
       // print level and offset of function call
       PT(level);
       if(p->name != NULL) printf("CALL STATEMENT function %s", p->name);
       if(p->s1 != NULL) {
	       printf(" \n");
	       PT(level);
	       printf("( \n");
	       ASTprint(level+1, p->s1);
	       PT(level);
	       printf(")");
       }
       printf(" level %d offset %d", p->symbol->level, p->symbol->offset);
       printf(" \n");
       break;
     case A_ARG:
       PT(level);
       printf("CALL argument \n");
       ASTprint(level+1, p->s1);
       ASTprint(level+1, p->s2);
       ASTprint(level, p->next);
       break;
     case A_ASSIGNMENT:
       // print the variable to be assigned, and the expression(s) it is assigned
       PT(level);
       printf("ASSIGNMENT STATEMENT \n");
       ASTprint(level+1, p->s1);
       PT(level);
       printf("is assigned \n");
       ASTprint(level+1, p->s2);
       ASTprint(level, p->next);
       break;
     case A_WHILE:
       PT(level);
       printf("WHILE STATEMENT \n");
       PT(level+1);
       printf("WHILE expression \n");
       ASTprint(level+2, p->s1);
       PT(level+1);
       printf("WHILE body \n");
       ASTprint(level+2, p->s2);
       ASTprint(level, p->next);
       break;
     case A_IF:
       PT(level);
       printf("IF STATEMENT \n");
       PT(level+1);
       printf("IF Expression \n");
       ASTprint(level+2, p->s1);
       PT(level+1);
       printf("IF body \n");
         ASTprint(level+2, p->s2->s1);
       if(p->s2->s2 != NULL) {
         PT(level+1);
	 printf("ELSE body \n");
	 ASTprint(level+2, p->s2->s2);
       }
       ASTprint(level, p->next);
       break;
     case A_PARAM:
       // print parameter name, and type
       // print brackets if value has been set to 1
       // print parameter level and offset
       PT(level);
       printf("Parameter ");
       printf("%s %s ", ASTtypeToString(p->my_data_type), p->name);
       if(p->value == 1) printf("[]");
       printf("level %d offset %d", p->symbol->level, p->symbol->offset);
       printf("\n");
       ASTprint(level, p->next);
       break;
     case A_EXSTAT:
       PT(level);
       printf("Expression STATEMENT \n");
       ASTprint(level+1, p->s1);
       ASTprint(level, p->next);
       break;
     default:
       printf("unknown AST Node type %d in ASTprint \n", p->type);
       break;
   } // end of switch

} // end of ASTprint

// PRE: pointers to actual and formal parameters
// 	parameters should be nodes that have my_data_type values set
// POST: 1 if valid, 0 if parameters are not the same type or length
int check_params(ASTnode *actuals, ASTnode *formals) {
	if(actuals == NULL && formals == NULL) return 1; // both are NULL, void or we have successfully reached the end, return valid
	if(actuals == NULL && formals != NULL) return 0; // check length of actuals and formals.
	if(actuals != NULL && formals == NULL) return 0;
	if(actuals->my_data_type != formals->my_data_type) return 0; // we have both so check their data types
	// else they are same, check the next set of params
	return check_params(actuals->next, formals->next); // recursively check the next parameters.
}

/* dummy main program so I can compile for syntax error independently   

   main()
{
} 
*/
