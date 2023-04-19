Lab 4 Symbol Table with YACC
Ryan Schwarzkopf
Feb 22, 2023

Enhanced from lab2.2: Lab 4 is a simple integer calculator program that implements variables.
Lex can now read variable names, and types; returns variable token with symbol companion value.
Yacc tokens take a type from union struct. Yacc syntax directed semantic action extended to declaration, definition, and reference of variables.
Symtable has Fetchaddress which searches for the address from a symbol. Symtable has Insert() to add a variable to the symbol table.

Lex globals: lineno, mydebug.     extern: n/a
Yacc globals:n/a                extern: lineno, mydebug, size
Symtable globals: size.         extern: mydebug

