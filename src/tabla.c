//#include <string.h>
//#include <stdlib.h>

int hash(int n)
{
	return n%TAM_HASH;
}

void iniciar_tabla(void)
{
	int i;
	for(i=0;i<TAM_HASH;i++)
	{
		tabla[i].cab=NULL;
		tabla[i].ultima=NULL;
	}
}

void ingresar_simbolo(int id,char* atr)
{
	int i;
	entrada *s;
	char *mem;

	mem=(char*)malloc(strlen(atr));
	s=(entrada*)malloc(sizeof(struct token));
	strcpy(mem,atr);

	s->atr=mem;
	s->id=id;
	s->sig=NULL;

	i=hash(*mem);

	if(tabla[i].cab==NULL)
	{
		tabla[i].cab=s; //Caso de la primera entrada
	}else (tabla[i].ultima)->sig=s;
	tabla[i].ultima=s;
	//ult_s=s;
}

entrada *buscar_simbolo(char* atr)
{
	int i,respuesta;
	entrada *s;

	i=hash(*atr);
	s=tabla[i].cab;

	while(s!=NULL)
	{
		   respuesta=strcmp(s->atr,atr);
		   if(respuesta==0)return s;
		   s=s->sig;
	}
	return 0;
}

/*void cargar_tokens(void)
{
	int i=0;
   FILE *dat;
   dat=fopen("tokens.dat","r");  //Archivo con los tokens
   printf("*********CARGANDO LA TABLA**********");
   while(!feof(dat))
	{
		printf("Se ingreso: %s\n",tok[i]);
		ingresar(i,tok[i]);
      i++;
	}
   printf("Se ingresaron %d, Presione un atecla para continuar...\n",i);
}*/

void imprimir_tabla(void)
{
	int i;
   entrada *s;
	for(i=0;i<TAM_HASH;i++)
	{
		s=tabla[i].cab;
		if(s!=NULL)printf("\n[Bucket %d]\n",i);
		while(s!=NULL)
		{
			printf(": %s %d :",s->atr,s->id);
			s=s->sig;
	  	}
	}

}
