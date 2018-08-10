%{
#include "y.g6.h"
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
char *yytext;
YYSTYPE yylval;
%}

ALFA 		[A-Za-z_]
PLUS            [\+]
MINUS           [\-]
TIMES           [\*]
DIVIDE          [/]
DIGIT           [0-9]
NUMBER          ({DIGIT}+)
PRINT           "print"
WHILE           "while"
IF		"if"
THEN            "then"
ELSE		"else"
DO              "do"

IDENT		{ALFA}({ALFA}|{DIGIT})*
WS              [ \t]*
ATRIB		"="
LP              "("
RP              ")"
LC              "{"
RC              "}"
VIRG            ","
PTV             ";"
RET             [\n]

%%

{WS}            {
                /* eat up white space */
                }
{PLUS}          {
                return _MAIS;
                }
{TIMES}         {
                return _MULT;
                }
{MINUS}         {
                return _MENOS;
                }
{DIVIDE}        {
                return _DIVID;
                }
{ATRIB}		{
		return _ATRIB;
		}
{LP}            {
                return _ABREPAR;
                }
{RP}            {
                return _FECHAPAR;
                }
{LC}            {
                return _ABRECOL;
                }
{RC}            {
                return _FECHACOL;
                }
{PTV}		{
		return _PTVIRG;
		}
{VIRG}          {
		return _VIRG;
		}
{NUMBER}        {
		strcpy(yylval.t.symbol, yytext);
                return _N;
                }
{PRINT}         {
		return _PRINT;
		}
{WHILE}         {
		return _WHILE;
		}
{IF}         	{
		return _IF;
		}
{WHILE}         {
		return _WHILE;
		}
{ELSE}         	{
		return _ELSE;
		}
{THEN}         {
		return _THEN;
		}
{DO}         	{
		return _DO;
		}
{IDENT}         {
		strcpy(yylval.t.symbol, yytext);
		return _V;
		}
{RET}           {
                return yytext[0];
                }
