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
e últimas p/ as temporarias
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
fimTrecho = topTab-1;// trecho dos símbolos do programa  
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
  fimTrecho=topTemp-1;  // trecho das temporárias
}; // do while
}; // da function printSymbTable


/*---------------------ADICIONAR AQUI-----------------------------------------*/
typedef enum {
ADD,
SUB,
MUL,
DIV,
STO,
PRINT, 
JUMP, 
JF, 
JT
} Operador;

char nomeOperador  [6] [7] = {
"ADD","SUB","MUL","DIV","STO","PRINT"};

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

void remenda (int posicao, Operador codop,int end1,int end2,int end3){
  quadrupla [posicao].op = codop;
  quadrupla [posicao].operando1 = end1;
  quadrupla [posicao].operando2 = end2;
  quadrupla [posicao].operando3 = end3;
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
%union{
  struct J{
    int indiceQuadrupla;
  } j;
}
%token _ATRIB _EOF _ABREPAR _FECHAPAR _ABRECOL _FECHACOL _VIRG
%token _MAIS _MENOS _MULT _DIVID _PRINT _WHILE _IF _THEN _ELSE _DO
%token _ERRO _INTTYPE _PTV
%token _N _V _ID
%type<t> B C S E T F _N _V _ID
%type<j> M N
%%
/* 
regras da gramatica e acoes semanticas
*/

P    : D _ABRECOL C _FECHACOL { 
        finaliza();
    }
     | {
        /* empty */
        finaliza ();
    }

D    : D V _PTV {
          /* D -> D V; */
    }
    | V _PTV {  
          /* D-> V; */
    }

V   : V _VIRG _ID { 
          /* V-> V, id */
          insertSymbTab($3.symbol, Variable);
    }
    | _INTTYPE _ID {  
          /* V-> int id */
          insertSymbTab($2.symbol, Variable);
    }

B    : _ABRECOL C _FECHACOL { 
            /* B-> {C} */	
    }	
    | S { 
            /* B-> S */	
    }

C    : C _PTV S { 
            /* C-> C; S */
    }	
     | S { 
            /* C-> S */
    } 

S    : _IF _ABREPAR E _FECHAPAR _THEN M B _ELSE M B {
            /* S-> if (E) then B else B */	
            remenda($6.indiceQuadrupla, JF, $3.intval, prox, NADA);
            remenda($9.indiceQuadrupla, JT, $3.intval, prox, NADA);
    }	
    | _IF _ABREPAR E _FECHAPAR _THEN M B { 
            /* S-> if (E) then B */	
            remenda($6.indiceQuadrupla, JF, $3.intval, prox, NADA);
    }     
    | _WHILE M _ABREPAR E _FECHAPAR M _DO B { 
            /* S-> while (E) do B */	
            gera(JUMP, $2.indiceQuadrupla, NADA, NADA);
            remenda($6.indiceQuadrupla, JF, $4.intval, prox, NADA);
    } 
    | _ID _ATRIB E { /* S-> id = E */	
            $1.intval = insertSymbTab($1.symbol, Variable);
            gera (STO,$3.intval,$1.intval,NADA);
            printf("\n");
    } 
    | _PRINT _ABREPAR E _FECHAPAR { 
            /* S-> print(E) */	
            $$.intval = temp(); 
		        gera (PRINT,$3.intval,NADA,NADA);
            printf("\n");
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
            $$.intval = temp(); 
            gera (MUL,$1.intval,$3.intval,$$.intval);
    } 
     | F {
            /* T-> F */
            $$.intval = $1.intval;
    } 

F    : _ID {
            /* F-> id */
            $$.intval=insertSymbTab($1.symbol, Variable);
    } 
    | _N {
            /* F-> n */
            $$.intval=insertSymbTab($1.symbol, Constant);
    }

M    : {
            $$.indiceQuadrupla = prox;
            prox++;
    }

N    : {
            $$.indiceQuadrupla = prox;
            prox++;
    }
%%

void atendeReclamacao () {
  int aux;
  aux = 0; // trying avoid compilation error in bison
  }
