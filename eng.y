%{
#define MYEXTERN extern
#include "unit.h"
#include "varArray.c"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int line_num;

void yyerror(const char* s) {
fprintf(stderr, "Parse error on line %d: %s\n", line_num, s);
exit(-1);

}



%}

%code requires
{
extern const struct unit_t UNIT_DEFAULT;
}
%union {
	char* sval;
	struct unit_t uval;
}

%token <sval> INT FLOAT IDENTIFIER OPERATOR TYPE UNITTYPE
%token ENDL ASSIGN LPAREN RPAREN UNIT
%type <sval> term expression statement
%type <uval> unitexpression unitstatement

%%
input: var_tsection statementsection
     ;
var_tsection: /* empty */ | var_tsection var_t
		  ;
statementsection: /* empty */ | statementsection statement
		;
var_t: TYPE IDENTIFIER ENDL 			{if (isDeclared(varArray, numDeclares, $1)){
							fprintf(stderr, "Error: Variable %s was previously declared\n", $1);
							exit(-1);
	      					}
						else {
						var_t newDeclaration; newDeclaration.name = strdup($2);
						newDeclaration.type = string2type_t(strdup($1));
						newDeclaration.units = UNIT_DEFAULT;
						appendElement(newDeclaration, &varArray, &varArrayCapacity, &numDeclares);
						printf("%s %s;\n", $1, $2);} } 

	   | TYPE IDENTIFIER unitstatement ENDL{if (isDeclared(varArray, numDeclares, $1)){
							fprintf(stderr, "Error: Variable %s was previously declared\n", $1);
							exit(-1);
	      					}
						else {
						var_t newDeclaration; newDeclaration.name = strdup($2);
						newDeclaration.type = string2type_t(strdup($1));
						newDeclaration.units = $3;
						appendElement(newDeclaration, &varArray, &varArrayCapacity, &numDeclares);
						printf("%s %s;\n", $1, $2);} } 
	;
unitstatement: UNIT unitexpression UNIT		{$$ = $2;}
	;
unitexpression: UNITTYPE			{$$ = UNIT_DEFAULT;
	      					string2unit_t($1, &$$);}
	| unitexpression OPERATOR UNITTYPE	{$$=$1;}

						/*{$$ = malloc(sizeof(char)*(strlen($1)+strlen($3)+1));
						char* unitexpression = strdup($1);
						char* operator = strdup($2);
						char* unit = strdup($3);
						$$ = strcat(strcat(unitexpression,operator),unit); }*/
	;
statement: IDENTIFIER ASSIGN expression ENDL	{if (isDeclared(varArray, numDeclares, $1)){
							printf("%s = %s;\n", $1, $3);}
						else {
							fprintf(stderr, "Error: Variable %s was not declared\n", $1);
							exit(-1);
						} }
	;
expression: term			{$$ = strdup($1)}
	| expression OPERATOR term	{$$ = malloc(sizeof(char)*(strlen($1)+strlen($3)+1));
					char* expression = strdup($1);
					char* operator = strdup($2);
					char* term = strdup($3);
					$$ = strcat(strcat(expression,operator),term);
					}
	;
term: IDENTIFIER			{if (isDeclared(varArray, numDeclares, $1)){
						$$ = strdup($1);}
					else {
						fprintf(stderr, "Error: Variable %s was not declared\n", $1);
						exit(-1);
					} }
	| FLOAT | INT			{$$ = strdup($1)}
	| LPAREN expression RPAREN	{$$ = malloc(sizeof(char)*(strlen($2)+2));
					char* lparen = strdup("(");
					char* expression = strdup($2);
					char* rparen = strdup(")");
					$$ = strcat(strcat(lparen, expression), rparen);
					}
    	;

%%
int main(int argc, char** argv) {
	FILE* input;
	if (argc > 1) {
		input = fopen(argv[1], "r");
	}
	else {
		printf("No input file specified. Stopping\n");
		return 0;
	}
	yyin = input;
	printf("int main(){\n");
	do {
		yyparse();
	} while (!feof(yyin));
	printf("}\n");
	int i;
	for (i=0; i<numDeclares; i++) {
		printf("%d %s %d\n", varArray[i].type, varArray[i].name, varArray[i].units.timePower);
	}
}
