#include <stdio.h>
#include <fcntl.h>
#include "siox.h"
#include "dbuffer.c"
#include "archivos.c"
#include "tabla.c"
#include "pila.c"
#include "parser.c"
#include "lexer.c"

char nombre_archivo[32];

int yyerror(char *s)
{
	printf ("Error gramatical en la linea #%d:' %s '\n",linea,yytext);
 	exit(1);
}


int main(int argc,char **argv)
{
   int l;
   char librerias[256];
   FILE* prev;

   printf("\nSIOXC v0.8 por Andres Agudelo Toro(aagudel6@eafit.edu.co)\n\n");

   get_exe_dir(directorio_actual,argv[0]);

   argv+=1;
   argc--;

   if(argc>0)
   {
		iniciar_buffers(argv[0]);
		strcpy(nombre_archivo,argv[0]);
   }
   else
   {
		iniciar_buffers("prog.ox");
   	strcpy(nombre_archivo,"prog.ox");
   }

   l=strlen(nombre_archivo);
   nombre_archivo[l-3]=0;

   sprintf(librerias,"%slib\\base.oxl",directorio_actual);
   head=fopen("header.out","w+b");
   inter=fopen("interm.out","w+b");
   prev=fopen("prev.out","w+b");
   basest=fopen(librerias,"r+");

   if(head==NULL)
   {
   	printf("No se pudo abrir el archivo auxiliar header.out\n");
      exit(1);
   }

   if(inter==NULL)
   {
   	printf("No se pudo abrir el archivo auxiliar interm.out\n");
      exit(1);
   }

   if(basest==NULL)
   {
   	printf("No se pudo abrir la libreria lib\\base.oxl\n");
      exit(1);
   }

   incluir(head,basest);
   fclose(basest);

   linea=1;
   iniciar_tabla();
   ult_s=(entrada*)malloc(sizeof(entrada));

   pila_if.t=0;
   *codigo1=0;
   *codigo2=0;
   *bloqued1=0;

   printf("\nCOMPILANDO EL ARCHIVO....");
   printf("\n-------------------------\n");

   strcat(nombre_archivo,".asm");
   remove(nombre_archivo);

   yyparse();

   salida=fopen(nombre_archivo,"w+b");

   concatenar(prev,head,inter);
   reparar(salida,prev);


   /*printf("\nTABLA DE SIMBOLOS\n");
   imprimir_tabla();*/
   printf("\n\nOK!\n");
   printf("\n\nCompilacion exitosa\n");
   printf("\n\nEl archivo de salida es %s\n",nombre_archivo);

   fclose(head);
   fclose(inter);
   fclose(prev);
   fclose(salida);

   remove("header.out");
   remove("interm.out");
   remove("prev.out");

   return 0;
}
