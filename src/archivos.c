void concatenar(FILE *dest,FILE *src1,FILE *src2)
{
	fseek(dest,0,SEEK_SET);
	fseek(src1,0,SEEK_SET);
	fseek(src2,0,SEEK_SET);
	do
	{
		fputc(fgetc(src1),dest);
	}while(!feof(src1));
	fseek(dest,-1,1);

	do
	{
		fputc(fgetc(src2),dest);
   }while(!feof(src2));
	fseek(dest,-1,1);
	fprintf(dest,"\n");
}

void incluir(FILE *dest,FILE *src)
{
   int nx;
	fseek(src,0,SEEK_SET);

	while(nx!=EOF)
	{
      nx=fgetc(src);
      if(nx!=EOF)
      {
      	fputc(nx,dest);
      }
	}
	fprintf(dest,"%c\n",13);
}

void reparar(FILE *dest,FILE *src)
{
   int nx,an=0;
	fseek(src,0,SEEK_SET);

	while(nx!=EOF)
	{
      nx=fgetc(src);
      if(nx!=EOF)
      {
         if(nx==10&&an!=13)
         {fprintf(dest,"%c%c",13,10);}
         else fputc(nx,dest);
      }
      an=nx;
	}
	fprintf(dest,"%c\n",13);
}

void get_exe_dir(char *dest,char *path)
{
	int l;
   l=strlen(path);
   while(path[l]!='\\')l--;
   path[l+1]=0;
   strcpy(dest,path);
}
