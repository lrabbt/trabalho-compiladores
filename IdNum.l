%{
#include "IdNum.tab.h"
#include <stdio.h>
#include <string.h>
char *yytext;
YYSTYPE yylval;

%}

DIGIT           [0-9]
ALFA		[A-Za-z_]
NUMBER          ({DIGIT}+)
IDENT		{ALFA}({ALFA}|{DIGIT})*
WS              [ \t]*
RET             [\n]

%%

{WS}            {
                /* eat up white space */
                }
{NUMBER}        { int aux;
		strcpy(yylval.t.symbol, yytext);
                return _N;
                }
{IDENT}         {int aux;
		strcpy(yylval.t.symbol, yytext);
		return _V;
		}
{RET}           {
                return yytext[0];
                }
