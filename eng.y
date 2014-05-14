%{
#define MYEXTERN extern
#include "unit.h"
#include "varArray.h"
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

%token <sval> INT FLOAT IDENTIFIER TYPE UNITTYPE COMPARISON
%token ENDSTATEMENT LPAREN RPAREN UNIT PRINT FUNCTION //ENDSTATEMENT is a semicolon terminal
%token DO IF END
%type <exval> term expression statement conditional
%type <uval> unitterm unitexpression unitstatement
%left ASSIGN
%left ADD SUBTRACT
%left MULTIPLY DIVIDE

%%
input: /* empty */ | input function
     ;
function: functiondeclaration var_tsection statementsection
     ;
functiondeclaration: FUNCTION IDENTIFIER ENDSTATEMENT	{ if (functionNumber>=0) { fprintf(OUTPUT, "}\n\n"); }
		   					fprintf(OUTPUT, "int %s() {\n", $2); functionNumber++;
		   					funcArray[functionNumber].name = $2;
							funcArray[functionNumber].varArrayCapacity = 0;
							funcArray[functionNumber].numDeclares = 0;
							}
		   ;
var_tsection: /* empty */ | var_tsection var_t
		  ;
statementsection: /* empty */ | statementsection statement | statementsection doloop | statementsection ifstatement
		;
doloop: dobegin statementsection doend
      ;
dobegin: DO INT					{ int i = 1; char loopVar[10]; sprintf(loopVar, "loop%d", i);
       						while (isDeclared(funcArray[functionNumber].varArray,
     							funcArray[functionNumber].numDeclares, loopVar)){
							i++; sprintf(loopVar, "loop%d",i);
						}
						fprintf(OUTPUT, "int %s;\n", loopVar);
       						fprintf(OUTPUT, "for (%s=0; %s<%s; %s++) {\n", loopVar, loopVar, $2, loopVar);}
      ;
doend:	END DO					{fprintf(OUTPUT, "}\n");}
      ;
ifstatement: ifbegin statementsection ifend
	   ;
ifbegin: IF LPAREN conditional RPAREN		{fprintf(OUTPUT, "if (%s){\n", $3.text);}
    ;
ifend: END IF					{fprintf(OUTPUT, "}\n");}
     ;
conditional: expression COMPARISON expression	{double ratio; if (checkUnits($1.units, $3.units, &ratio)){
							if (ratio==1) {
								sprintf($$.text, "%s %s %s", $1.text, $2, $3.text);
							}
							else {
								sprintf($$.text,"%s %s %e*(%s)", $1.text,$2, ratio, $3.text);
							}
						}
						else {
							char buf1[20]; char buf2[20];
							printUnits($1.units, buf1);
							printUnits($3.units, buf2);
							fprintf(stderr, "Error: Tried to assign incompatible units on line %d: \"%s\" to \"%s\".\n", line_num, buf2, buf1);
							exit(-1);

						} }
	   ;
var_t: TYPE IDENTIFIER ENDSTATEMENT 		{if (isDeclared(funcArray[functionNumber].varArray,
     							funcArray[functionNumber].numDeclares, $2)){
						fprintf(stderr, "Error: Variable %s was previously declared\n", $2);
						exit(-1);
	      					}
						else {
						var_t newDeclaration; newDeclaration.name = strdup($2);
						newDeclaration.type = string2type_t(strdup($1));
						newDeclaration.units = UNIT_DEFAULT;
						appendElement(newDeclaration, &(funcArray[functionNumber].varArray),
							&(funcArray[functionNumber].varArrayCapacity),
							&(funcArray[functionNumber].numDeclares));
						fprintf(OUTPUT, "%s %s;\n", $1, $2);} } 

	| TYPE IDENTIFIER unitstatement ENDSTATEMENT 		{if (isDeclared(funcArray[functionNumber].varArray,
     							funcArray[functionNumber].numDeclares, $2)){
						fprintf(stderr, "Error: Variable %s was previously declared\n", $2);
						exit(-1);
	      					}
						else {
						var_t newDeclaration; newDeclaration.name = strdup($2);
						newDeclaration.type = string2type_t(strdup($1));
						newDeclaration.units = $3;
						appendElement(newDeclaration, &(funcArray[functionNumber].varArray),
							&(funcArray[functionNumber].varArrayCapacity),
							&(funcArray[functionNumber].numDeclares));
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
	| unitexpression DIVIDE unitexpression	{ double ratio; $$ = divUnits($1, $3, &ratio);
						if (ratio!=1) {
							fprintf(stderr, "Error: Mixed units on line %d\n", line_num);
							exit(-1);
						} }
	;
unitterm: UNITTYPE				{string2unit_t($1, &$$);}
	| LPAREN unitexpression RPAREN		{ $$ = $2; }
	;
statement: IDENTIFIER ASSIGN expression ENDSTATEMENT	{if (isDeclared(funcArray[functionNumber].varArray,
	 							funcArray[functionNumber].numDeclares, $1)){
	 						double ratio;
	 						if (checkUnits(getUnits(funcArray[functionNumber].varArray,
								funcArray[functionNumber].numDeclares, $1), $3.units, &ratio)) {
								if (ratio==1) {
									fprintf(OUTPUT, "%s = %s;\n", $1, $3.text);
								}
								else {
									fprintf(OUTPUT, "%s = %e*(%s);\n", $1, ratio, $3.text);
								}
							}
							else {
								char buf1[20]; char buf2[20];
								printUnits(getUnits(funcArray[functionNumber].varArray,
									funcArray[functionNumber].numDeclares, $1), buf1);
								printUnits($3.units, buf2);
								fprintf(stderr, "Error: Tried to assign incompatible units on line %d: \"%s\" to \"%s\".\n", line_num, buf2, buf1);
								exit(-1);
							}
						}
						else {
							fprintf(stderr, "Error: Variable %s was not declared\n", $1);
							exit(-1);
						} }
	| PRINT LPAREN IDENTIFIER RPAREN ENDSTATEMENT	{int i; if (i = isDeclared(funcArray[functionNumber].varArray,
								funcArray[functionNumber].numDeclares, $3)){
							char buf[20];
							printUnits(funcArray[functionNumber].varArray[i-1].units, buf);
							if (funcArray[functionNumber].varArray[i-1].type==INT_T) {
								fprintf(OUTPUT, "printf(\"%s = %%d %s\\n\", %s);\n", $3, buf, $3);
							}
							else {
								fprintf(OUTPUT, "printf(\"%s = %%f %s\\n\", %s);\n", $3, buf, $3);
							}
						}
						else {
							fprintf(stderr, "Error: Variable %s was not declared\n", $3);
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
						sprintf($$.text,"%s%s(%e*%s)", expression, operator, ratio, term);
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
						sprintf($$.text,"%s%s(%e*%s)", expression, operator, ratio, term);
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
						sprintf($$.text,"%s%s(%e*%s)", expression, operator, ratio, term);
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
						sprintf($$.text,"%s%s(%e*%s)", expression, operator, ratio, term);
					}
					}
	;
term: IDENTIFIER			{if (isDeclared(funcArray[functionNumber].varArray,
    						funcArray[functionNumber].numDeclares, $1)){
						$$.text = strdup($1);
						$$.units = getUnits(funcArray[functionNumber].varArray,
							funcArray[functionNumber].numDeclares, $1);}
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
	int testFlag=0;
	if (argc == 3) {
		if (strcmp(argv[1], "-t")==0){
			testFlag = 1;
			OUTPUT = stdout;
		}
		input = fopen(argv[2], "r");
	}
	else if (argc == 2) {
		input = fopen(argv[1], "r");
		OUTPUT = fopen("a.c", "w");
	}
	else {
		printf("No input file specified. Stopping\n");
		return 0;
	}
	yyin = input;
	fprintf(OUTPUT, "#include <stdio.h>\n");
	do {
		yyparse();
	} while (!feof(yyin));
	fprintf(OUTPUT, "}\n");
	int i;
	int j;
/*	for (j=0; j<=functionNumber; j++) {
		printf("On function number %d, %s:\n", j, funcArray[j].name);
		printf("There are %d variables\n", funcArray[j].numDeclares);
		for (i=0; i<funcArray[j].numDeclares; i++) {
			printf("%d %s\t", funcArray[j].varArray[i].type, funcArray[j].varArray[i].name);
	//		printUnits(funcArray[j].varArray[i].units);
			printf("\n");
		}
	}*/
	fclose(input);
	fclose(OUTPUT);
	if (!testFlag) {
		system("gcc a.c");
	}
}
