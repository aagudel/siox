typedef struct PILA
{
	int p[256];
	int t;
}pila;

void push(pila *s,int v)
{
   if(s->t<255)
   {
   	s->p[s->t]=v;
   	s->t++;
   }
   else
   {
   	printf("Error de pila.");
      exit(1);
   }
}

int pop(pila *s)
{
   if(s->t>0)
   {
		s->t--;
      return s->p[s->t];
   }
   else
   {
   	printf("Error de pila.");
      exit(1);
   }
}
