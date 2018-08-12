# Trabalho de Compiladores #

## Compilando ##

### Executando o Script ###

No terminal:

```bash
./compile.sh
```

### Executando Diretamente os Comandos ###

No terminal:

```bash
bison -d g6.y
flex g6.l
cc lex.yy.c g6.tab.c -o g6.tab
```

## Executando o Parser ##

Para executar o parser:

```bash
./g6
```