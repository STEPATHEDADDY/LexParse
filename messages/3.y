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

	void addSpaces (int count) {
		int i;
		printf("\n");
		for (i = 0; i < count * 5; i++)
		{
			printf(" ");
		}
	}

	void printColorful(char *string)
	{
		char *color;
			if ((string == "SUBJECT") || (string == "PREDICATE"))
				color = KMAG;
			else if ((string == "NOUN") || (string == "VERB") ||
				(string == "DIR_OBJ") || (string == "ARTICLE"))
				color = KWHT;
				else color = KCYN;
			printf("%s%s ", color, string);

	}

	void printNode (struct Node* node, int deep) {
		if (node == NULL) return;
		//printf("(");
		addSpaces(deep);
		printColorful(node->nodeType);
		printNode(node->leftOperand, deep + 1);
		//printf("%i", node->nodeType);
		printNode(node->rightOperand, deep + 1);
		//addSpaces(deep);
		//printf("\n");
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
			printf("\t");
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
		//pointers = realloc(pointers, sizeof(char*) * (j - position));
		printLALRParsing(node->leftOperand, position);
		printLALRParsing(node->rightOperand, position + 1);
		if (node->leftOperand != NULL)
		{	
			printf("\t");
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

/*
	TYPE:
		1) DIROBJ
		2) PREDICATE
		3) SUBJECT
		4) SENTENCE
*/

%}

%union {
	char *string;
	struct Node *Tree;
}
%token END_PUNCT
%token <string> ARTICLE
%token <string> NOUN
%token <string> VERB
%type <Tree> DIR_OBJ
%type <Tree> SUBJECT
%type <Tree> PREDICATE
%type <Tree> SENTENCE
%start LIST
	
%%

LIST:

|	LIST CORRECT
;

CORRECT:
	SENTENCE { 
		printf(KWHT "\nCorrect!\n");
		free(pointers);
		//printNode($1);
	}
;

SENTENCE:
	SUBJECT PREDICATE END_PUNCT	{ 
		$$ = makeNode($1, $2, "SENTENCE"); 
		printf("\n");
		printNode($$, 1);
		printf("\n");

		struct Node *root;
		root = makeNode($$, NULL, "ROOT");
		initializePointers();
		printf(KWHT "TDPARSE:\n\t");
		printTDParsing(root);

		printf("\n\nLALRPARSE:\n");
		j = 0;
		printLALRParsing(root, 0);
	}
;

SUBJECT:			
	NOUN {	
		struct Node *lval, *noun;
		lval = makeSimpleNode($1);
		noun = makeNode(lval, NULL, "NOUN");
		$$ = makeNode(noun, NULL, "SUBJECT");
		//printf("%s\n", $1);
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
		//printf("%s\n", $1);
		//printf("%s\n", $2);
	}
;

DIR_OBJ:
	ARTICLE NOUN { 
		//$1 = makeNode(NULL, NULL, "ARTICLE");
		//$2 = makeNode(NULL, NULL, "NOUN");
		struct Node *lval, *rval, *article, *noun;
		lval = makeSimpleNode($1);
		rval = makeSimpleNode($2);
		article = makeNode(lval, NULL, "ARTICLE");
		noun = makeNode(rval, NULL, "NOUN");
		$$ = makeNode(article, noun, "DIR_OBJ");
		//printf("%s ", $1);
		//printf("%s\n", $2);
		//printNode($$, 1);
	}
;

%%
