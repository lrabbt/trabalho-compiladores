guest-z0jEJh@pc28:/var/guest-data/compilg6$ bison -d g6.y
guest-z0jEJh@pc28:/var/guest-data/compilg6$ flex g6.l
guest-z0jEJh@pc28:/var/guest-data/compilg6$ cc lex.yy.c g6.tab.c -o g6.tab
g6.y:66:6: warning: conflicting types for ‘yyerror’ [enabled by default]
 void yyerror(const char *str)
      ^
g6.y:56:5: note: previous implicit declaration of ‘yyerror’ was here
     yyerror (ptMsg);
     ^
guest-z0jEJh@pc28:/var/guest-data/compilg6$ ls
g6  g6.l  g6.l~  g6.tab.c  g6.tab.h  g6.y  g6.y~  lex.yy.c
guest-z0jEJh@pc28:/var/guest-data/compilg6$ ./g6
...>g6 
>x 1 y 2 z 3

> Variable: x 0 
>
> Numerical Constant: 1 1 
>
> Variable: y 0 
>
> Numerical Constant: 2 2 
>
> Variable: z 0 
>
> Numerical Constant: 3 3 
>End normal compilation! 
