%{
    #include <stdio.h>
	#include <stdlib.h>
	#include "node.h"
	#define KNRM  "\x1B[0m"
	#define KRED  "\x1B[31m"
	#define KGRN  "\x1B[32m"
	#define KYEL  "\x1B[33m"
	#define KBLU  "\x1B[34m"
	#define KMAG  "\x1B[35m"
	#define KCYN  "\x1B[36m"
	#define KWHT  "\x1B[37m"    

	void yyerror(char *s) {
      fprintf (stderr, "%s\n", s);
	}
	
	struct Node *Tree;
	
	struct Node *makeSimpleNode(char *word) {
		struct Node *node = malloc(sizeof(struct Node));
	    node->nodeType = word;
		node->rightOperand = NULL;
	    node->leftOperand = NULL;
		return node;
	}

	struct Node *makeNode(struct Node *left,
	  struct Node *right, char* type) {
		struct Node *node = malloc(sizeof(struct Node));
	    node->nodeType = type;
		node->rightOperand = right;
	    node->leftOperand = left;
		return node;
	}

	void addSpaces (char symbol, int count) {
		int i;
		for (i = 0; i < (count - 2) * 5; i++)
		{
			printf(" ");
		}
		if ((count - 1) > 0)
		{
			for (i = 0; i < 5; i++)
			{
				printf(KYEL "%c", symbol);
			}
		}
	}

	void printColorful(char *string)
	{
		char *color;
			if ((string == "TODOVERB") || (string == "SUBJECT") ||
				(string == "PREDICATE") || (string == "SENTENCE") ||
				(string == "QUESTION") || (string == "DIR_OBJ") ||
				(string == "SPECWORD") || (string == "SPECQUESTION"))
				color = KBLU;
			else if ((string == "NOUN") || (string == "VERB") ||
				(string == "ARTICLE"))
				color = KWHT;
				else color = KCYN;
			printf("%s%s ", color, string);

	}

	void printNode (struct Node* node, int deep) {
		if (node == NULL) return;
		addSpaces('-', deep);
		printColorful(node->nodeType);
		printf("\n");
		printNode(node->leftOperand, deep + 1);
		printNode(node->rightOperand, deep + 1);
		return;
	}

	int k = 1, j = 0, i;
	char **pointers; 
	void printTDParsing(struct Node* node)
	{
		if (node == NULL) return;
		if (node->rightOperand != NULL)
		{
			k += 1;
			j = k - 2;
			pointers = realloc(pointers, sizeof(char*) * k);
			pointers[k - 1] = node->rightOperand->nodeType;
		}
		if (node->leftOperand != NULL)
		{
			pointers[j] = node->leftOperand->nodeType;
			for (i = 0; i < k; i++)
			{
				printColorful(pointers[i]);
			}
			printf("\n");
		}
		printTDParsing(node->leftOperand);
		j = k - 1;
		printTDParsing(node->rightOperand);
	}
	
	int isEnd = 0;
	void printLALRParsing(struct Node* node, int position)
	{
		if (k == position)
		{
			isEnd = 1;
		}
		if (node == NULL) return;
		printLALRParsing(node->leftOperand, position);
		printLALRParsing(node->rightOperand, position + 1);
		if (node->leftOperand != NULL)
		{	
			k -= j;
			for (i = 0; i < k; i++)
			{
				printColorful(pointers[i]);
			}
			printf("\n");
		}
		pointers[position] = node->nodeType;
		if((isEnd) && (k - 2 == position))
		{
			j = 1;
		}
	}

	void initializePointers()
	{
		pointers = malloc(k * sizeof(char));
	}

	void doTreeOperations(struct Node* node)
	{
		printf(KWHT "\nCorrect!\n");

		printf("\n");

		k = 1;
		j = 0; 
		printf("AST:\n");
		printNode(node, 1);
		printf("\n");

		struct Node *root;
		root = makeNode(node, NULL, "ROOT");
		initializePointers();

		printf(KWHT "TDPARSE:\n");
		isEnd = 0;
		printTDParsing(root);

		printf(KWHT "\n\nLALRPARSE:\n");
		j = 0;
		printLALRParsing(root, 0);

		free(pointers);

		printf(KWHT "\n");
	}
%}

%union {
	char *string;
	struct Node *Tree;
}
%token END_PUNCT
%token <string> ARTICLE
%token <string> NOUN
%token <string> VERB
%token <string> TODOVERB
%token <string> SPECWORD
%type <Tree> DIR_OBJ
%type <Tree> SUBJECT
%type <Tree> PREDICATE
%type <Tree> SENTENCE
%type <Tree> QUESTION
%type <Tree> SPECQUESTION
%start LIST
	
%%

LIST:

|	LIST CORRECT
;

CORRECT:
	SENTENCE { 
		doTreeOperations($1);
	}
|	QUESTION {
		doTreeOperations($1);
	}
|	SPECQUESTION {
		doTreeOperations($1);
	}
;

SPECQUESTION:
	SPECWORD QUESTION {
		struct Node *lval, *specword;
		lval = makeSimpleNode($1);
		specword = makeNode(lval, NULL, "SPECWORD");
		$$ = makeNode(specword, $2, "SPECQUESTION");
	}
;

QUESTION:
	TODOVERB SENTENCE {
		struct Node *lval, *todoverb;
		lval = makeSimpleNode($1);
		todoverb = makeNode(lval, NULL, "TODOVERB");
		$$ = makeNode(todoverb, $2, "QUESTION");
	}
;

SENTENCE:
	SUBJECT PREDICATE END_PUNCT	{ 
		$$ = makeNode($1, $2, "SENTENCE"); 
	}
;

SUBJECT:			
	NOUN {	
		struct Node *lval, *noun;
		lval = makeSimpleNode($1);
		noun = makeNode(lval, NULL, "NOUN");
		$$ = makeNode(noun, NULL, "SUBJECT");
	}

;

PREDICATE:
	VERB {
		struct Node *lval, *verb;
		lval = makeSimpleNode($1);
		verb = makeNode(lval, NULL, "VERB");
		$$ = makeNode(verb, NULL, "PREDICATE");
	}
|	VERB DIR_OBJ {	
		struct Node *lval, *verb;
		lval = makeSimpleNode($1);
		verb = makeNode(lval, NULL, "VERB");
		$$ = makeNode(verb, $2, "PREDICATE"); 
	}
;

DIR_OBJ:
	ARTICLE NOUN { 
		struct Node *lval, *rval, *article, *noun;
		lval = makeSimpleNode($1);
		rval = makeSimpleNode($2);
		article = makeNode(lval, NULL, "ARTICLE");
		noun = makeNode(rval, NULL, "NOUN");
		$$ = makeNode(article, noun, "DIR_OBJ");
	}
;

%%
