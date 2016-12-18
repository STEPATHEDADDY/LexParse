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
	ENUM WORD EXPRS ';'
;

EXPRS:
	EXPR
|	EXPRS ',' EXPR

EXPR:			
	WORD
|	EXPR '=' NUM
|	EXPR '=' WORD
;

%%
