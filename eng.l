%{
#include "unit.h"
#include "eng.tab.h"
int line_num=1;
%}
%x unit

digit [0-9]
alpha [a-zA-Z]

%%

\-?{digit}+					{ yylval.sval=strdup(yytext); return INT; }
\-?{digit}*"."{digit}+|{digit}+"."{digit}* 	{ yylval.sval=strdup(yytext); return FLOAT; }
"function"					{ return FUNCTION; }
"int"|"float"|"double"				{ yylval.sval=strdup(yytext); return TYPE; }
"if"						{ return IF; }
"do"						{ return DO; }
"end"						{ return END; }
"print"						{ return PRINT; }
"+"						{ return ADD; }
"-"						{ return SUBTRACT; }
"*"						{ return MULTIPLY; }
"/"						{ return DIVIDE; }
"&&"						{ return AND; }
"||"						{ return OR; }
">"|"<"|">="|"<="|"=="|"!="			{ yylval.sval=strdup(yytext); return COMPARISON; }
{alpha}({alpha}|{digit})*			{ yylval.sval=strdup(yytext); return IDENTIFIER; }
";"						{ return ENDSTATEMENT; }
"="						{ return ASSIGN; }
"("						{ return LPAREN; }
")"						{ return RPAREN; }
"["						{ return LBRACKET; }
"]"						{ return RBRACKET; }
","						{ return COMMA; }
[\t ]						{ ; }
"\n"						{ line_num++; }
"\\"						{ BEGIN(unit); return UNIT; }
.						{ printf("Unrecognized character on line %d: %s\n",line_num, yytext); exit(-1);}
<unit>"\\"					{ BEGIN(INITIAL); return UNIT; }
<unit>{alpha}+					{ yylval.sval=strdup(yytext); return UNITTYPE; }
<unit>"*"					{ return MULTIPLY; }
<unit>"/"					{ return DIVIDE; }
<unit>"("					{ return LPAREN; }
<unit>")"					{ return RPAREN; }
<unit>.						{ printf("Illegal character in unit statement on line %d: %s\n",
						line_num, yytext); exit(-1);}

%%
