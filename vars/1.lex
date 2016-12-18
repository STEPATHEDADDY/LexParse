%{
	#include "3.tab.h"
%}

%option yylineno
%option noyywrap

%%

[/][/].*\n					;

enum						{
								return ENUM;
							}

[0-9]+						{
								return NUM;
							}
(?i:([a-z_][a-z0-9]*))		{
								return WORD;
							}
[ \t\r\n]					;
.							{
								return *yytext; 
							}
%%
