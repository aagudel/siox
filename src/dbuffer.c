/*dbuffer.c******************************************************************/
//#include <stdio.h>

//#define BL_TAM 128
#define DBL_BL_TAM BL_TAM*2+2 //258
#define FIN_BL_1 BL_TAM       //128
#define FIN_BL_2 DBL_BL_TAM-1 //257
#define BL_1 0
#define BL_2 BL_TAM+1         //129

char buffer[DBL_BL_TAM];
int ib=-1;
FILE *fuente;

void cargar(int blq)
{
	int cu=0;
	long oft=0;
	cu=fread(buffer+blq,BL_TAM,1,fuente);
	if(cu==0)		//Fin de archivo
	{
		oft=ftell(fuente)%(BL_TAM);
		buffer[blq+oft]=EOF;
	}
}

int caracter(void)
{
	ib++;
	if(buffer[ib]==EOF)
	{
		if(ib==FIN_BL_1)
		{
			cargar(BL_2);
			ib++;
		}
		else if(ib==FIN_BL_2)
		{
			cargar(BL_1);
			ib=0;
		}
		else return EOF;
	}
	if(buffer[ib]<0)return 126;
   if(buffer[ib]=='\n')linea++;
	return buffer[ib];
}

FILE *iniciar_buffers(char *archivo)
{
	int i;
  	for(i=0;i<DBL_BL_TAM;i++)buffer[i]=EOF; //Limpia
	fuente=fopen(archivo,"r+b");
        if(fuente==NULL)
        {
                printf("Error de archivo ' %s '.\n",archivo);
                exit(1);
        }
        cargar(BL_1);
	return fuente;
}
