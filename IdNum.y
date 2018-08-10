%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

extern int yylex ();

typedef enum {
	Variable,
	Constant
} Entity;

typedef struct {
  char     asciiOfSource [20];
  Entity   entt;
  int      valueVarOrCte;
} SymbTab;

char *msg1 = "exceeded the maximum length for a string";
char *msg2 = "string exceeds maximum size";
char *msg3 = "overflow on receiver string";
char *msg4 = "unknow entity in source program";

SymbTab symbTab [100];

int	indSymb,  
	indTemp;

int	topTab=0;   // first 50 entries are programmer symbols
int	topTemp=50; // last  50 entries are temporary

int searchSymbTab (char *symb){ 
  int k;
  for (k = 0; k < topTab; k++)
    if (strcmp(symb,symbTab[k].asciiOfSource) == 0)
      return k;
  return topTab;
};

int insertSymbTab (char *symb, Entity whichEntt) {
  int existingSym, current, aux;
  
  existingSym = searchSymbTab (symb);
  if (existingSym < topTab) return existingSym;
  current = topTab;
  if ((whichEntt == Variable) || (whichEntt == Constant)) {
     strcpy(symbTab[current].asciiOfSource,symb);
     symbTab[current].entt = whichEntt;
     }
  else {
    char * ptMsg = (char *) malloc (80);
    strcpy(ptMsg,"Unknown entity type: "); 
    strcat(ptMsg,symb); 
    yyerror (ptMsg);
    };
  if (whichEntt == Constant)
     symbTab[current].valueVarOrCte = atoi(symb);
  if (whichEntt == Variable) 
     symbTab[current].valueVarOrCte = 0;  
  topTab++;
  return current;
};

void yyerror(const char *str)
{
  printf("error: %s\n",str);
  exit (1);
};

int yywrap()
{
  return 1;
};

int main()
{
  printf("\n \n...>IdNum \n>"); 
  yyparse();
  return 0;
};

%}

%union{struct T{char symbol[21]; int intval;}t;}
%token _N _V
%type<t> E _N _V

%%	

S	: Stm S
	| /* empty */ {printf("End normal compilation! \n"); exit (0);}
	;
Stm	: E {
	  int aux;
          switch (symbTab[$1.intval].entt) {
	    case Variable: printf(" Variable: ");break;
	    case Constant: printf(" Numerical Constant: ");break;
	    default: yyerror(msg4);break;
	    };
	  printf("%s ", symbTab[$1.intval].asciiOfSource);
	  printf("%d \n", symbTab[$1.intval].valueVarOrCte);
	  printf(">");
	  }
	;
E	: _V {$$.intval=insertSymbTab($1.symbol, Variable);
              printf("\n>");}

	| _N {$$.intval=insertSymbTab($1.symbol, Constant);
	      printf("\n>");}
	;
%%

void finaliza () {
  int aux;
  aux = 0; // trying avoid compilation error in bison
  }
