%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
extern int yylex ();
 
#define NADA		9999
#define FRACASSO	9998
#define ACHOUDIFVAR	9997

char *msg4 = "unknow entity in source program";

typedef enum {
	Variable,
	Constant,
	Temporary,
	Function,
	Procedure
} Entity;

/*
SymbTab: 1as 50 entradas p/ simbolos do fonte
e �ltimas p/ as temporarias
*/
typedef struct {
  char     asciiOfSource [20];
  Entity   entt;
  int      value;
} SymbTab;

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
     symbTab[current].value = atoi(symb);
  if (whichEntt == Variable) 
     symbTab[current].value = 0;  
  topTab++;
  return current;
};
int temp () { 
	char nomeTemporaria[4];
	int retorno;
        sprintf(nomeTemporaria,"t%d",topTemp-50);
	strcpy(symbTab[topTemp].asciiOfSource,nomeTemporaria);
	symbTab[topTemp].entt = Temporary;
        retorno=topTemp;
	topTemp++;
	return (retorno);
};
void printSymbTable () {
int i, j, inicio, fimTrecho;
inicio=0;
j=0;
fimTrecho = topTab-1;// trecho dos s�mbolos do programa  
while (j <= 1) {
  for (i=inicio; i <= fimTrecho; i++) { 
    switch (symbTab[i].entt) {
      case Variable: printf("> Variable: ");break;
      case Constant: printf("> Numerical Constant: ");break;
      case Temporary: printf("> Temporary: ");break;
      case Function: printf("> Function: ");break;
      case Procedure: printf("> Procedure: ");break;
      default: yyerror(msg4);break;
    };
    printf("%s ", symbTab[i].asciiOfSource);
    printf("%d \n", symbTab[i].value);
    };// do for
  j++;
  inicio = 50;
  fimTrecho=topTemp-1;  // trecho das tempor�rias
}; // do while
}; // da function printSymbTable


/*---------------------ADICIONAR AQUI-----------------------------------------*/
typedef enum {
ADD,
SUB,
MUL,
DIV,
ATRIB,
PRINT
} Operador;

struct Quadrupla {
	Operador        op;
	int             operando1;
	int             operando2;
	int             operando3;
	} quadrupla [ 100 ];

int prox;

void gera (Operador codop,int end1,int end2,int end3){
	quadrupla [prox].op = codop;
	quadrupla [prox].operando1 = end1;
	quadrupla [prox].operando2 = end2;
	quadrupla [prox].operando3 = end3;
	prox++;
	};
void imprimeQuadrupla(){
  int r; 
  for(r=0;r<prox;r++) 
    printf("%d %d %d %d\n",
            quadrupla[r].op,                
               quadrupla[r].operando1,
                  quadrupla[r].operando2,
                     quadrupla[r].operando3);
  
}; //da funcao imprimeQuadrupla

void finaliza () {
  printSymbTable ();
  imprimeQuadrupla ();
  printf("End normal compilation! \n");
  exit(0);
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
  printf("\n \n>G7 \n>"); 
  yyparse();
  return 0;
};
%}
%union{
  struct T{
    char symbol[21]; 
    int intval;}t;
 }
%token _ATRIB _EOF _ABREPAR _FECHAPAR _ABRECOL _FECHACOL _PTVIRG _VIRG
%token _MAIS _MENOS _MULT _DIVID _PRINT _WHILE _IF _THEN _ELSE _DO
%token _ERRO
%token _N _V
%type<t> B C S L E T F _N _V _id _t _M _B _e
%%
/* 
regras da gramatica e acoes semanticas
*/

P    : D _ABRECOL C _FECHACOL /* P-> D {C} */
     | {
        /* empty */
        finaliza ();
     }
D    : D V _PTV { 
           /* D-> D V; */
		   $1.intval = insertSymbTab($1.symbol, Variable);
		   gera(STO,$3.intval,$1.intval,NADA);
		   printf("\n");
    }
    |V _PTV{  
           /* D-> V; */
           gera(PRINT,$3.intval, NADA, NADA);
		   printf("\n");
    }
V   : V _VIRG _id { 
           /* V-> V, id */
           $$.intval = temp(); 
		   gera (ADD,$1.intval,$3.intval,$$.intval);
    }
    | int _id{  
            /* V-> int id */
            $$.intval = temp(); 
		    gera (SUB,$1.intval,$3.intval,$$.intval);
    }
B    : _ABRECOL C _FECHACOL { 
            /* B-> {C} */	
            $$.intval = temp(); 
		    gera (MUL,$1.intval,$3.intval,$$.intval);
    }	
    | S { 
            /* B-> S */	
            $$.intval = temp(); 
		    gera (DIV,$1.intval,$3.intval,$$.intval);
    }

C    : _ABRECOL C _FECHACOL { 
            /* C-> C; S */	
            $$.intval = temp(); 
		    gera (MUL,$1.intval,$3.intval,$$.intval);
    }	
     | S { /* C-> S */	
         $$.intval = temp(); 
		 gera (DIV,$1.intval,$3.intval,$$.intval);
    } 
S    : _IF E _THEN _M _B _ELSE _B {
            /* S-> if (E) then B else B */	
            $$.intval = temp(); 
		    gera (MUL,$1.intval,$3.intval,$$.intval);
    }	
    | _IF E _THEN _M _B { 
            /* S-> if (E) then B */	
            $$.intval = temp(); 
		    gera (DIV,$1.intval,$3.intval,$$.intval);
    }     
    | _WHILE _N E _M _DO _B { 
            /* S-> while (E) do B */	
            $$.intval = temp(); 
		    gera (DIV,$1.intval,$3.intval,$$.intval);
    } 
            | _id _ATRIB E { /* S-> id = E */	
            $$.intval = temp(); 
		    gera (DIV,$1.intval,$3.intval,$$.intval);
    } 
    | _PRINT _ABREPAR E _FECHAPAR { 
            /* S-> print(E) */	
            $$.intval = temp(); 
		    gera (DIV,$1.intval,$3.intval,$$.intval);
    } 

E    : E _MAIS T { 
            /* E-> E+T */
            $$.intval = temp(); 
		    gera (ADD,$1.intval,$3.intval,$$.intval);
    }
    | E _MENOS T{  
            /* E-> E-T */
            $$.intval = temp(); 
		    gera (SUB,$1.intval,$3.intval,$$.intval);
    }
    | T	 { 
            /* E-> T */	
            $$.intval = $1.intval;
    } 
T    : T _MULT F {
            /* T-> T*F */
		    $$.intval=insertSymbTab($1.symbol, Variable);
    } 
     | F {
            /* T-> F */
	    $$.intval=insertSymbTab($1.symbol, Constant);
    } 
F    : _id {
            /* F-> id */
            $$.intval=insertSymbTab($1.symbol, Variable);
    } 
    | _N {
            /* F-> n */
            $$.intval=insertSymbTab($1.symbol, Constant);
    }
%%

void atendeReclamacao () {
  int aux;
  aux = 0; // trying avoid compilation error in bison
  }
