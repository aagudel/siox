%{
/**PARSER Y GENERADOR DE CODIGO PARA EL ASEMBLER DEL PIC 16F873**/

#define OUT fprintf
#define PRINT sprintf
#define COPY strcpy
#define ADD strcat

extern char *yytext;

int cm=0x23;/*Contador de memoria*/
int ci=0;	/*Contador de if's*/
int le=0;	/*Longitud expresion*/
int mp=0;   /*Numero maximo de parametros*/
int cp=0;	/*Contador de parametros*/
int ap=0;	/*Apuntador de parametros*/
int nfa=1;	/*Numero de funcion Actual*/

entrada *fa; /*Funcion actual*/

pila pila_if;

char codigo1[1024];
char codigo2[1024];
char bloqued1[1024];

void _expresion_PUNTO(void);

void _expr_com_(void);
void _expr_com_izq(void);
void _expr_com_der(void);

void _expresionr_(void);
void IF_ELSE(void);
void WHILE_(void);
void bloque_IF(void);
void bloque_ELSE(void);
void bloque_WH(void);

void _funcion_decl(void);
void _parametro_decl(void);
void _fin_parametros_decl(void);
void _varl_inic(void);
void _fin_decl_funciones(void);
void _funcion_IDENT(void);
void _funcion_(void);
void _paramv_(void);
void _verif_funcion(void);

void op_MEN_Q(void);
void op_MAY_Q(void);
void op_MEN_IG(void);
void op_MAY_IG(void);
void op_IG_QUE(void);
void op_DIF_QUE(void);


void expr_sim_SUMA_termino(void);
void expr_sim_RESTA_termino(void);
void expr_sim_OR_termino(void);
void expr_sim_AND_termino(void);
void expr_sim_XOR_termino(void);
void termino(void);


%}

%token IDENT 1000
%token NUMERO 1501
%token CADENA 1502

//Signos de puntuación
%token NOMBRE_IZQ 2000  //<<
%token NOMBRE_DER 2001  //>>
%token DECL_FUNC  2002  //#fnn#
%token DECL_PPAL  2003  //#ppl#
%token DECL_FIN   2004  //#end#
%token BLOQUE_IZQ 2005  //[
%token BLOQUE_DER 2006  //]
%token PUNTO      2007  //.
%token COMENTARIO 2008  //;  	;Comentarios
%token DECL_VARS  2009  //#var#
%token LLAVE_IZQ 	2010  //{
%token LLAVE_DER 	2011  //}

//Palabras reservadas
%token INTEGER 3000      //byte
%token BUFFER  3001      //buffer
%token RETORNO 3002      //ret
%token WHILE   3003      //while
%token DO      3004      //do
%token IF      3005      //if
%token THEN    3006      //then
%token ELSE    3007      //else
%token GOTO    3008      //goto

//Operadores por orden de precedencia
%token PAR_IZQ 4000      //(
%token PAR_DER 4001      //)
%token D_FUNC  4002      //-> 	;Definición de función
%token D_VECT  4003      //%  	;definición de vector
%token P_VECT  4004      //@  	;posicion de vector

%token NEGAC   5000      //^  	;negacion
%token SUMA    5001      //+
%token RESTA   5002      //-
%token MASMAS  5003      //++
%token MENMEN  5004      //--

%token MULT    6000      //*
%token DIV     6001      // /		;divisón
%token MOD     6002      // \  	;modulo

%token MEN_Q   7000      //<
%token MEN_IG  7001      //<= 	;menor igual
%token MAY_Q   7002      //>
%token MAY_IG  7003      //>= 	;mayor igual

%token IG_QUE  8000      //=? 	;igual lógico
%token DIF_QUE 8001      //!= 	;diferente

%token AND     9000      //&  	;and
%token OR      9002      //|  	;or
%token XOR     9003      //%  	;xor

%token IGUAL   10000     //=
%token COMA    10001     //,

%%
programa:	nombre
		DECL_VARS   	{OUT(SALIDA1,"\n;--VARIABLES-------------------\n\n\tORG\t0\n");}
		declarac
		DECL_FUNC		{OUT(SALIDA1,"\n\tGOTO\t_PPAL\n;--FUNCIONES-------------------\n\n\tCLRW\n\n");}
		decl_funciones	{_fin_decl_funciones();}
		DECL_PPAL		{OUT(SALIDA1,"\n;--PRINCIPAL--------------------\n\n_PPAL\tCLRW\n\n");}
		propos         {OUT(SALIDA1,"\n\tSLEEP\n");}
		DECL_FIN			{OUT(SALIDA1,"\n\tEND\n;------------------------------\n");}
		;

nombre: /*VACIO*/
		|NOMBRE_IZQ
		IDENT		{OUT(SALIDA0,";%s\n\n",yytext);}
		NOMBRE_DER
		;

decl_funciones:	/*VACIO*/
		|funcion_d decl_funciones
		;

funcion_d:	tipo IDENT 				{_funcion_decl();}
		PAR_IZQ parametros PAR_DER {_fin_parametros_decl();}
      declarac
     	LLAVE_IZQ               {*codigo1=0;}
      propos
      LLAVE_DER               {OUT(SALIDA1,"\tRETURN\n");nfa++;}
		;

retorno: /*VACIO*/
		|expresion
		;

declarac:	/*VACIO*/
		|decl_var declarac
		;

decl_var:	var_inic
		|var_noinic
		;

var_inic:	tipo IDENT		{COPY(s_izq,ult_s->atr);OUT(SALIDA0,"%s\tEQU\t0%XH\n",s_izq,cm);cm++;}
		IGUAL
		NUMERO		{OUT(SALIDA1,"\tMOVLW\t0%XH\n\tMOVWF\t%s\n",atoi(yytext),s_izq);}
		PUNTO
		;

var_noinic:	tipo
		IDENT
		PUNTO			{OUT(SALIDA0,"%s\tEQU\t0%XH\n",ult_s->atr,cm);cm++;}
		;

parametros:	/*VACIO*/
		|lista_param
		;

lista_param: parametro
		|parametro COMA lista_param
		;

parametro:	tipo IDENT            {_parametro_decl();}
		;

propos: /*VACIO*/
		|prop propos
		;

prop:	sentencia
		|IDENT 							{COPY(s_izq,ult_s->atr);}
		IGUAL expresion PUNTO		{_expresion_PUNTO();}
		|funcion PUNTO             {_funcion_();}
      |IDENT MASMAS PUNTO        {OUT(SALIDA1,"\tINCF\t%s\n",ult_s->atr);}
		|IDENT MENMEN PUNTO        {OUT(SALIDA1,"\tDECF\t%s\n",ult_s->atr);}
      |IDENT MAY_Q					{OUT(SALIDA1,"%s:\n",ult_s->atr);}
      |GOTO	IDENT PUNTO				{OUT(SALIDA1,"\tGOTO\t%s\n",ult_s->atr);}
      |RETORNO retorno PUNTO		{OUT(SALIDA1,"%s\tRETURN\n\n",codigo1);}
		;

sentencia:	sent_if
		|sent_wh
      ;

sent_if: IF PAR_IZQ expresionr {_expresionr_();}
      PAR_DER
		bloque
      alternat
      ;

sent_wh: WHILE 		{WHILE_();}
      PAR_IZQ
		expresionr		{_expresionr_();}
      PAR_DER
		bloque         {bloque_WH();}
		;

alternat: /*VACIO*/    {bloque_IF();}
		|ELSE            {IF_ELSE();}
      bloque           {bloque_ELSE();}
      ;

bloque:	LLAVE_IZQ	  	{}
		propos
		LLAVE_DER 			{}
		;

expresion:	expr_com	{_expr_com_();}

expresionr:	expr_sim 		{_expr_com_izq();}
		operador_r
		expr_sim    	{_expr_com_der();}
		;

expr_com:	expr_sim {}
  		|funcion		{_funcion_();}
      ;

expr_sim:	expr_sim SUMA termino 		{expr_sim_SUMA_termino();}
		|expr_sim RESTA termino				{expr_sim_RESTA_termino();}
		|expr_sim OR termino					{expr_sim_OR_termino();}
      |expr_sim AND termino            {expr_sim_AND_termino();}
      |expr_sim XOR termino            {expr_sim_XOR_termino();}
		|termino									{termino();}
		;

termino:	IDENT		{}
		|NUMERO		{}
		;

funcion:	IDENT 	 				{_funcion_IDENT();}
		PAR_IZQ params PAR_DER  {_verif_funcion();}
		;

params: /*VACIO*/
		|lista_params
		;

lista_params:	paramv	{_paramv_();}
		|paramv	{_paramv_();}
      COMA lista_params
		;

paramv: paramv SUMA terminov 				{expr_sim_SUMA_termino();}
		|paramv RESTA terminov				{expr_sim_RESTA_termino();}
		|paramv OR terminov					{expr_sim_OR_termino();}
		|terminov								{termino();}
		;

terminov:	IDENT
		|NUMERO
		;

tipo: /*VACIO*/
		|INTEGER
		;

operador_r: MEN_Q		{op_MEN_Q();}
		|MAY_Q         {op_MAY_Q();}
		|MEN_IG     	{op_MEN_IG();}
		|MAY_IG			{op_MAY_IG();}
		|IG_QUE			{op_IG_QUE();}
		|DIF_QUE  		{op_DIF_QUE();}
		;

%%

/**********************************************************************/
/**TRADUCTOR***********************************************************/
/**********************************************************************/

void _expresion_PUNTO(void)
{
   OUT(SALIDA1,"%s",codigo1);
	if(strcmp(s_izq,"W"))
   	OUT(SALIDA1,"\tMOVWF\t%s\n",s_izq);
}

void _expr_com_(void)
{
	le=0;
}

void _expr_com_izq(void)
{
 	le=0;
}

void _expr_com_der(void)
{
	le=0;
}

void _expresionr_(void)
{
   OUT(SALIDA1,"%s",codigo1);
	OUT(SALIDA1,"%s",bloqued1);
   push(&pila_if,ci);
   ci++;
}

void IF_ELSE(void)
{
   int a;
   a=pila_if.p[pila_if.t-1];
	OUT(SALIDA1,"\tGOTO\t_NIF%d\n",a);
   OUT(SALIDA1,"_ELS%d:\n",a);
}

void WHILE_(void)
{
	OUT(SALIDA1,"_WHL%d:\n",ci);
}

void bloque_IF(void)
{
	OUT(SALIDA1,"_ELS%d:\n",pop(&pila_if));
}

void bloque_ELSE(void)
{
	OUT(SALIDA1,"\n_NIF%d:\n",pop(&pila_if));
}

void bloque_WH(void)
{
   int a=pop(&pila_if);
	OUT(SALIDA1,"\tGOTO\t_WHL%d\n",a);
	OUT(SALIDA1,"_ELS%d:\n",a);
}

void expr_sim_SUMA_termino(void)
{
   char cadtemp[256];
   switch(ult_s->id)
	{
		case IDENT:
			PRINT(cadtemp,"\tADDWF\t%s,0\n",ult_s->atr);
   		break;
      case NUMERO:
     		PRINT(cadtemp,"\tADDLW\t%0XH\n",atoi(ult_s->atr));
   		break;
	}
   ADD(codigo1,cadtemp);
}

void expr_sim_RESTA_termino(void)
{
   char cadtemp[256];

   ADD(codigo1,"\tMOVWF\tS0__\n");

   switch(ult_s->id)
	{
		case IDENT:
         PRINT(cadtemp,"\tMOVF\t%s,0\n",ult_s->atr);
			break;
      case NUMERO:
         PRINT(cadtemp,"\tMOVLW\t0%XH\n",atoi(ult_s->atr));
   		break;
	}

   ADD(codigo1,cadtemp);
   ADD(codigo1,"\tSUBWF\tS0__,0\n");
}

void expr_sim_OR_termino(void)
{
   char cadtemp[256];

   switch(ult_s->id)
	{
		case IDENT:
			PRINT(cadtemp,"\tIORWF\t%s,0\n",ult_s->atr);
   		break;
      case NUMERO:
     		PRINT(cadtemp,"\tIORLW\t%0XH\n",atoi(ult_s->atr));
   		break;
	}
	ADD(codigo1,cadtemp);
}

void expr_sim_AND_termino(void)
{
   char cadtemp[256];

   switch(ult_s->id)
	{
		case IDENT:
			PRINT(cadtemp,"\tANDWF\t%s,0\n",ult_s->atr);
   		break;
      case NUMERO:
     		PRINT(cadtemp,"\tANDLW\t%0XH\n",atoi(ult_s->atr));
   		break;
	}
	ADD(codigo1,cadtemp);
}

void expr_sim_XOR_termino(void)
{
   char cadtemp[256];

   switch(ult_s->id)
	{
		case IDENT:
			PRINT(cadtemp,"\tXORWF\t%s,0\n",ult_s->atr);
   		break;
      case NUMERO:
     		PRINT(cadtemp,"\tXORLW\t%0XH\n",atoi(ult_s->atr));
   		break;
	}
	ADD(codigo1,cadtemp);
}

void termino(void)
{
	*codigo1=0;
   if(strcmp(ult_s->atr,"W"))
  	switch(ult_s->id)
	{
  		case IDENT:
     		PRINT(codigo1,"\tMOVF\t%s,0\n",ult_s->atr);
        	break;
      case NUMERO:
        	PRINT(codigo1,"\tMOVLW\t0%XH\n",atoi(ult_s->atr));
   		break;
	}
}

void _funcion_decl(void)
{
   fa=buscar_simbolo(ult_s->atr);
   OUT(SALIDA1,"%s:\n",ult_s->atr);
   fa->par=(char*)malloc(512);
   *fa->par=0;
	cp=0;
}

void _parametro_decl(void)
{
  	OUT(SALIDA0,"%s\tEQU\t0%XH\n",ult_s->atr,cm);
   ADD(fa->par,ult_s->atr);
   ADD(fa->par,"|");

	cp++;
   cm++;
   if(cp>mp)mp=cp;
}

void _fin_parametros_decl(void)
{
	fa->id=fa->id+cp;
}

void _fin_decl_funciones(void)
{
	nfa=0;
   if(mp>5)
   {
   	printf("\nAdvertencia: las funciones de este programa pueden estar\n");
      printf("utilizando demasiados parametros. Recuerde que los parametros\n");
      printf("son variables globales.\n");
   }

}

void _funcion_IDENT(void)
{
   fa=buscar_simbolo(ult_s->atr);
	cp=0;
   ap=0;
}

void _funcion_(void)
{
	OUT(SALIDA1,"\tCALL\t%s\n",fa->atr);
   *codigo1=0;
}

void _paramv_(void)
{
   int i=0;
   char c=0;
   OUT(SALIDA1,"%s",codigo1);
   OUT(SALIDA1,"\tMOVWF\t");
   while(1)
   {
    	c=fa->par[ap];
      if(c!='|')
			OUT(SALIDA1,"%c",c);
      else
      	break;
   	ap++;
   }
   OUT(SALIDA1,"\n");
	cp++;
   ap++;
}

void _verif_funcion(void)
{
	if(fa->id-IDENT<cp||fa->id-IDENT>cp)
   {
   	printf("\nFunción no declarada o cantidad invalidad de parametros ");
      printf("en la llamada a la funcion '%s'\nen la linea #%d\n",fa->atr,linea);
      exit(1);
   }
}
void op_MEN_Q(void)
{
   OUT(SALIDA1,"%s",codigo1);
 	OUT(SALIDA1,"\tMOVWF\tS1__\n");
	PRINT(bloqued1,"\tSUBWF\tS1__,0\n\tBTFSC\tSTATUS,0\n\tGOTO\t_ELS%d\n",ci);
}

void op_MAY_Q(void)
{
   char cadtemp[256];

  	COPY(bloqued1,"\tMOVWF\tS1__\n");
   ADD(bloqued1,codigo1);
   PRINT(cadtemp,"\tSUBWF\tS1__,0\n\tBTFSC\tSTATUS,0\n\tGOTO\t_ELS%d\n",ci);
   ADD(bloqued1,cadtemp);
}

void op_MEN_IG(void)
{
   char cadtemp[256];

  	COPY(bloqued1,"\tMOVWF\tS1__\n");
   ADD(bloqued1,codigo1);
	PRINT(cadtemp,"\tSUBWF\tS1__,0\n\tBTFSS\tSTATUS,0\n\tGOTO\t_ELS%d\n",ci);
   ADD(bloqued1,cadtemp);
}

void op_MAY_IG(void)
{
   OUT(SALIDA1,"%s",codigo1);
 	OUT(SALIDA1,"\tMOVWF\tS1__\n");
 	PRINT(bloqued1,"\tSUBWF\tS1__,0\n\tBTFSS\tSTATUS,0\n\tGOTO\t_ELS%d\n",ci);
}

void op_IG_QUE(void)
{
   OUT(SALIDA1,"%s",codigo1);
 	OUT(SALIDA1,"\tMOVWF\tS1__\n");
	PRINT(bloqued1,"\tSUBWF\tS1__,0\n\tBTFSS\tSTATUS,2\n\tGOTO\t_ELS%d\n",ci);
}

void op_DIF_QUE(void)
{
   OUT(SALIDA1,"%s",codigo1);
 	OUT(SALIDA1,"\tMOVWF\tS1__\n");
	PRINT(bloqued1,"\tSUBWF\tS1__,0\n\tBTFSC\tSTATUS,2\n\tGOTO\t_ELS%d\n",ci);
}

