%{
#define MYEXTERN
#include "unit.h"
#include "eng.tab.h"
int line_num=1;
%}
%x unit

digit [0-9]
alpha [a-zA-Z]
addop [\+\-]
multop [\*/]

%%

\-?{digit}+					{ yylval.sval=strdup(yytext); return INT; }
\-?{digit}*"."{digit}+|{digit}+"."{digit}* 	{ yylval.sval=strdup(yytext); return FLOAT; }
"int"|"float"|"double"				{ yylval.sval=strdup(yytext); return TYPE; }
{addop}|{multop}				{ yylval.sval=strdup(yytext); return OPERATOR; }
{alpha}({alpha}|{digit})*			{ yylval.sval=strdup(yytext); return IDENTIFIER; }
"="						{ return ASSIGN; }
"("						{ return LPAREN; }
")"						{ return RPAREN; }
[\t ]						;
\n						{ line_num++; return ENDL; }
"\\"						{ BEGIN(unit); return UNIT; }
.						{ printf("Unrecognized character on line %d: %s\n", line_num, yytext); }
<unit>"\\"					{ BEGIN(INITIAL); return UNIT; }
<unit>{alpha}+					{ yylval.sval=strdup(yytext); return UNITTYPE; }
<unit>{multop}					{ yylval.sval=strdup(yytext); return OPERATOR; }
<unit>.						{ printf("Illegal character in unit statement on line %d: %s\n",
						line_num, yytext); }

%%
