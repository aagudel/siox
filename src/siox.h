#include <stdio.h>
#include <string.h>

#define TAM_HASH 101
#define L_PANTALLA 23
#define BL_TAM 4096

#define SALIDA0 head
#define SALIDA1 inter

typedef struct token
{
	int	id;             //Identificador
	char *atr;            //Atributo
   char *par;
	struct token *sig;    //Apuntador al siguiente token
}entrada;

typedef struct bucket
{
	entrada *ultima;      //Ultima entrada
	entrada *cab;         //Apuntador a la cabeza de la lista
}base;

entrada *ult_s;	          //ultimo simbolo
char s_izq[255];		    //simbolo izquierdo
char ult_term[255];	    //ultimo termino

FILE *inter;
FILE *head;
FILE *basest;
FILE *salida;

char directorio_actual[256];

base tabla[TAM_HASH];
int linea;
