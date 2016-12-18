%{
    #include <stdio.h>
    void yyerror(char *s) {
      fprintf (stderr, "%s\n", s);
    }
%}

%token NUM
%token WORD
%token ENUM
%start LIST

%%

LIST:

|	LIST CORRECT
;

CORRECT:
	EVALUATE	{ printf("Correct!\n"); }
;

EVALUATE:
	ENUM WORD ';'
|	ENUM FULLEXPRNAME ';'	 
;

FULLEXPRNAME:
	NAMEFULLEXPR
|	FULLEXPRNAME WORD
;

NAMEFULLEXPR:	
	FULLEXPR
|	WORD NAMEFULLEXPR
;

FULLEXPR:		
	'{' EXPRS '}'
;

EXPRS:			
	EXPR
|	EXPRS ',' EXPR
;

EXPR:			
	WORD
|	WORD '=' NUM
;

%%
