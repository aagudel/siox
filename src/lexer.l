%{
#define OBTENER_TOKEN yylex
#define YY_INPUT(buf,result,max_size) \
{ \
int c = caracter(); \
result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
}
#define F_BUFSIZ 1024
FILE *incl;
char arch_incl[64];
%}

LETRA           [a-zA-Z_]
DIGITO          [0-9]
CAR_CAD	        [^"]
CAR_COM		[^\n]
CAR_SCOM	[^:]
CAR_ASM		[^\]]
N_LINEA		[\n]
ESPACIO         [ \t]
N_VAL		[~]

%%

{ESPACIO}+	{}

"<<"		return NOMBRE_IZQ;
">>" 		return NOMBRE_DER;

"#var#" 	return DECL_VARS;
"#fnn#"        	return DECL_FUNC;
"#ppl#"		return DECL_PPAL;
"#end#" 	return DECL_FIN;


"." 				return PUNTO;
"["				return BLOQUE_IZQ;
"]" 				return BLOQUE_DER;
"{"				return LLAVE_IZQ;
"}" 				return LLAVE_DER;
":"{CAR_SCOM}*":" 		{}//COMENTARIO;
";"{CAR_COM}*"\n" 		{}//COMENTARIO;
"["{CAR_ASM}*"]" 		{yytext[yyleng-1]=0;
				OUT(SALIDA1,"\n%s\n",yytext+1);}//ASEMBLER;
#* 				{}//SEPARADOR;
"@"{CAR_COM}*"\n"	{
							yytext[yyleng-2]=0;
							sprintf(arch_incl,"%slib\\%s",directorio_actual,yytext+1);
                     incl=fopen(arch_incl,"r+");
                     if(incl==NULL)
                     {
                     	printf("No se pudo encontrar el archivo '%s'",yytext+1);
                        exit(1);
                     }
                     incluir(SALIDA1,incl);
						}

"("	return PAR_IZQ;
")"     return PAR_DER;
"->"	return D_FUNC;
"%"	return D_VECT;

"^"	return NEGAC;
"+"	return SUMA;
"-"	return RESTA;
"++"  return MASMAS;
"--"  return MENMEN;

"*" 	return MULT;
"/"	return DIV;
"\\"	return MOD;

"<" 	return MEN_Q;
"<="	return MEN_IG;
">"	return MAY_Q;
">="    return MAY_IG;

"=?" 	return IG_QUE;
"!="	return DIF_QUE;

"&" 	return AND;
"|"	return OR;
"%"	return XOR;

"="	return IGUAL;
","	return COMA;

"byte" 			return INTEGER;
"buffer"		return BUFFER;
"return"		return RETORNO;
"while"			return WHILE;
"do"			return DO;
"if"			return IF;
"then"			return THEN;
"else"			return ELSE;
"goto"      return GOTO;

"$"{LETRA}({LETRA}|{DIGITO})*	{/*if(buscar_simbolo(yytext)==NULL)ingresar_simbolo(IDENT,yytext);*/
				strcpy(ult_s->atr,yytext+1);
				ult_s->id=IDENT;
				return IDENT;}

{LETRA}({LETRA}|{DIGITO})*  	{strcat(yytext,"_");
				if(buscar_simbolo(yytext)==NULL)ingresar_simbolo(IDENT,yytext);
				strcpy(ult_s->atr,yytext);
				ult_s->id=IDENT;
				return IDENT;}

{DIGITO}+		 	{/*if(buscar_simbolo(yytext)==NULL)ingresar_simbolo(NUMERO,yytext);*/
				strcpy(ult_s->atr,yytext);
				ult_s->id=NUMERO;
				return NUMERO;}
\"{CAR_CAD}*\"  		return CADENA;

{N_LINEA} 		{/*linea++;*/}

{N_VAL}			{printf("Caracter desconocido en la linea #%d.\n",linea);exit(1);}

.			{if(*yytext!=13){printf("Lexema no valido en la linea #%d: %c\n",linea,*yytext);exit(1);}}

%%
