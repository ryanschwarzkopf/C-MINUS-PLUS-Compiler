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
       PT(level);
       printf("Variable %s %s", ASTtypeToString(p->my_data_type), p->name);
       if(p->value != 0) printf("[%d]", p->value);
       printf(" \n");
       ASTprint(level, p->s1);
       ASTprint(level, p->next);
       break;
     case A_FUNCTIONDEC :  
       PT(level); 
       printf("Function %s %s", ASTtypeToString(p->my_data_type), p->name); 
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
       PT(level);
       if(p->name != NULL) {
         printf("Write String  %s \n", p->name);
       } else if(p->s1 != NULL) { // it is an expression
         printf("Write Expression \n");
	 ASTprint(level+1, p->s1);
       }
       ASTprint(level, p->next);
       break;
     case A_NUM : // leaf
       PT(level);
       printf("NUMBER value %d \n", p->value);  
       break;
     case A_EXPR :
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
       printf(" \n");
       break;
     case A_RETURN:
       PT(level);
       printf("RETURN STATEMENT \n");
       ASTprint(level+1, p->s1);
       ASTprint(level, p->next);
       break;
     case A_CALL:
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
       PT(level);
       printf("Parameter ");
       printf("%s %s", ASTtypeToString(p->my_data_type), p->name);
       if(p->value == 1) printf("[]");
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



/* dummy main program so I can compile for syntax error independently   

   main()
{
}
/* */
