#include <stdio.h>
#include <process.h>

int main(int argc,char *argv[])
{
	printf("%s\n",argv[0]);
	printf("%s\n",argv[1]);
  	printf("%s\n",argv[2]);

   execlp("mpasm.exe",NULL);
   perror("exec error");
   exit(1);

   return 0;


}
