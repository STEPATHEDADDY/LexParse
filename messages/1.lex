%{
	#include "node.h"
	#include "3.tab.h"
%}

%option yylineno
%option noyywrap

%%

[/][/].*\n					;

(?i:a|the|an) {
	yylval.string = strdup(yytext);
	return ARTICLE;
}

(?i:cat|dog|Steve|song|bottle|lamp|paper) {
	yylval.string = strdup(yytext);
	return NOUN;
}

(?i:holds|takes|drops|sends) {
	yylval.string = strdup(yytext);
	return VERB;
}

(?i:do|does|did) {
	yylval.string = strdup(yytext);
	return TODOVERB;
}

(?i:why|what|when|how) {
	yylval.string = strdup(yytext);
	return SPECWORD;
}

[.!?]+ {
	return END_PUNCT;
}

[ \t\r\n]					;
. {
	return *yytext; 
}

%%
