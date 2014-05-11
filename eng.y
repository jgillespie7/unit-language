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
FILE* OUTPUT;

%}

%code requires
{
extern const struct unit_t UNIT_DEFAULT;
extern unit_t addUnits();
extern unit_t subUnits();
extern unit_t multUnits();
extern unit_t divUnits();
extern void printUnits();
typedef struct expression_t {
	char* text;
	unit_t units;
}expression_t;
}
%union {
	char* sval;
	struct unit_t uval;
	struct expression_t exval;
}

%token <sval> INT FLOAT IDENTIFIER TYPE UNITTYPE
%token ENDL LPAREN RPAREN UNIT
%type <exval> term expression statement
%type <uval> unitterm unitexpression unitstatement
%left ASSIGN
%left ADD SUBTRACT
%left MULTIPLY DIVIDE

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
						line_num++;
						var_t newDeclaration; newDeclaration.name = strdup($2);
						newDeclaration.type = string2type_t(strdup($1));
						newDeclaration.units = UNIT_DEFAULT;
						appendElement(newDeclaration, &varArray, &varArrayCapacity, &numDeclares);
						fprintf(OUTPUT, "%s %s;\n", $1, $2);} } 

	   | TYPE IDENTIFIER unitstatement ENDL{if (isDeclared(varArray, numDeclares, $1)){
							fprintf(stderr, "Error: Variable %s was previously declared\n", $1);
							exit(-1);
	      					}
						else {
						line_num++;
						var_t newDeclaration; newDeclaration.name = strdup($2);
						newDeclaration.type = string2type_t(strdup($1));
						newDeclaration.units = $3;
						appendElement(newDeclaration, &varArray, &varArrayCapacity, &numDeclares);
						fprintf(OUTPUT, "%s %s;\n", $1, $2);} } 
	;
unitstatement: UNIT unitexpression UNIT		{$$ = $2;}
	     ;
unitexpression: unitterm			{$$ = $1;}
	| unitexpression MULTIPLY unitexpression{ double ratio; $$ = multUnits($1, $3, &ratio);
						if (ratio!=1) {
							fprintf(stderr, "Error: Mixed units on line %d\n", line_num);
							exit(-1);
						} }
	| unitexpression DIVIDE unitexpression	{ double ratio; $$ = divUnits($1, $3), &ratio;
						if (ratio!=1) {
							fprintf(stderr, "Error: Mixed units on line %d\n", line_num);
							exit(-1);
						} }
	;
unitterm: UNITTYPE				{string2unit_t($1, &$$);}
	| LPAREN unitexpression RPAREN		{ $$ = $2; }
	;
statement: IDENTIFIER ASSIGN expression ENDL	{if (isDeclared(varArray, numDeclares, $1)){
	 						double ratio;
	 						if (checkUnits(varArray, numDeclares, $1, $3.units, &ratio)) {
							line_num++;
							if (ratio==1) {
								fprintf(OUTPUT, "%s = %s;\n", $1, $3.text);
							}
							else {
								fprintf(OUTPUT, "%s = %f*(%s);\n", $1, ratio, $3.text);
							}
							}
							else {
								fprintf(stderr, "Error: Tried to assign incompatible units on line %d.\n", line_num);
								char buf1[20]; char buf2[20];
								printUnits(getUnits(varArray, numDeclares, $1), buf1),
								printUnits($3.units, buf2);
								printf("%s to %s", buf1, buf2);
								exit(-1);
							}
						}
						else {
							fprintf(stderr, "Error: Variable %s was not declared\n", $1);
							exit(-1);
						} }
	;
expression: term			{$$.text = strdup($1.text); $$.units = $1.units}
	| expression ADD expression	{$$.text = malloc(sizeof(char)*(strlen($1.text)+strlen($3.text)+1));
					double ratio;
					$$.units = addUnits($1.units, $3.units, &ratio);
					char* expression = strdup($1.text);
					char* operator = strdup("+");
					char* term = strdup($3.text);
					if (ratio==1) {
						sprintf($$.text,"%s%s%s", expression, operator, term);
					}
					else {
						sprintf($$.text,"%s%s(%f*%s)", expression, operator, ratio, term);
					}
					}
	| expression SUBTRACT expression{$$.text = malloc(sizeof(char)*(strlen($1.text)+strlen($3.text)+1));
					double ratio;
					$$.units = subUnits($1.units, $3.units, &ratio);
					char* expression = strdup($1.text);
					char* operator = strdup("-");
					char* term = strdup($3.text);
					if (ratio==1) {
						sprintf($$.text,"%s%s%s", expression, operator, term);
					}
					else {
						sprintf($$.text,"%s%s(%f*%s)", expression, operator, ratio, term);
					}
					}
	| expression MULTIPLY expression{$$.text = malloc(sizeof(char)*(strlen($1.text)+strlen($3.text)+1));
					double ratio;
					$$.units = multUnits($1.units, $3.units, &ratio);
					char* expression = strdup($1.text);
					char* operator = strdup("*");
					char* term = strdup($3.text);
					if (ratio==1) {
						sprintf($$.text,"%s%s%s", expression, operator, term);
					}
					else {
						sprintf($$.text,"%s%s(%f*%s)", expression, operator, ratio, term);
					}
					}
	| expression DIVIDE expression	{$$.text = malloc(sizeof(char)*(strlen($1.text)+strlen($3.text)+1));
					double ratio;
					$$.units = divUnits($1.units, $3.units, &ratio);
					char* expression = strdup($1.text);
					char* operator = strdup("/");
					char* term = strdup($3.text);
					if (ratio==1) {
						sprintf($$.text,"%s%s%s", expression, operator, term);
					}
					else {
						sprintf($$.text,"%s%s(%f*%s)", expression, operator, ratio, term);
					}
					}
	;
term: IDENTIFIER			{if (isDeclared(varArray, numDeclares, $1)){
						$$.text = strdup($1);
						$$.units = getUnits(varArray, numDeclares, $1);}
					else {
						fprintf(stderr, "Error: Variable %s was not declared\n", $1);
						exit(-1);
					} }
	| FLOAT				{$$.text = strdup($1); $$.units=UNIT_DEFAULT;}
	| INT				{$$.text = strdup($1); $$.units=UNIT_DEFAULT;}
	| FLOAT	unitstatement		{$$.text = strdup($1); $$.units=$2;}
	| INT unitstatement		{$$.text = strdup($1); $$.units=$2;}
	| LPAREN expression RPAREN	{$$.text = malloc(sizeof(char)*(strlen($2.text)+2));
					char* lparen = strdup("(");
					char* expression = strdup($2.text);
					char* rparen = strdup(")");
					$$.text = strcat(strcat(lparen, expression), rparen);
					$$.units = $2.units
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
//	OUTPUT = fopen("a.cc", "w");
	OUTPUT = stdout;
	fprintf(OUTPUT, "int main(){\n");
	do {
		yyparse();
	} while (!feof(yyin));
	fprintf(OUTPUT, "}\n");
	int i;
	for (i=0; i<numDeclares; i++) {
		printf("%d %s\t", varArray[i].type, varArray[i].name);
		//printUnits(varArray[i].units);
		printf("\n");
	}
}
