         /* simple lex program which removes comments from a source program
            The main key is that a variable "comment" is set when the start of a comment
            is seen and then unset when the ending set is seen.  It is possible to have
            two starts closed by on end.

            Shaun Cooper
            January 2015
 
         */
/*
	Added int return type to main(). Added global variable: newLine with lex 
	rule to count the number of new lines. Enhance error messages to include
	newlines.

	Ryan Schwarzkopf
	Jan 27, 2023
*/
        int comment = 0;
        int debug=1;  /* prints out debug statements if desired */
	int newLine=0;
%%
"/*"	{
	if (comment && debug) fprintf(stderr,
		" >>>>>>>> line %d: Possible Nested comment <<<<<<<<<<\n", newLine);
	comment = 1;
	}

"*/"	{
          if (!comment) printf("%s",yytext); /*print out if it is not in a comment */
  	  comment = 0;
	}
"\n"	{
	newLine++;
	}
.       { if (!comment) printf("%s",yytext);}

%%

int yywrap(void)
{ return 1;
}

int main()
{
  yylex();
  
}

