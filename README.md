# SIOX

SIOX is a simple programming language for the PIC-16F873.  SIOXC is a simple compiler producing PIC assembler. Siox was coded in LEX, YACC and C and was integrated to the Microchip MPLAB IDE. Source code, executable and docs are in Spanish. This code was written in 2001 for a School project.

Sioxc es un compilador del lenguaje Siox que genera código assembler del PIC 16f873. Siox es un lenguaje de programación que permite funciones simples (no recursivas), sentencias matemáticas (sumas y restas), lógicas (or, and) y de control de flujo (if, if else, while, etc), considerando las limitaciones del PIC.

Siox fue escrito en Lex, Bison y C, es un compilador de una sola pasada
que traduce por sintaxis.

# EL PROGRAMA BÁSICO

Un programa en Siox se compone de tres bloques, cualquier programa debe
incluir:

    #var#
    ;Declaración de variables
    #fnn#
    ;Declaración de funciones
    #ppl#
    ;El programa principal
    #end#

El programa anterior es aceptado por el compilador sioxc. Un programa
más completo sería:

    #var#

     byte a=10.
     byte b=30.

    #fnn#
     byte max(byte p1,p2)
     {
      if(p1>=p2)
      {
       return p1.
      }
      else
      {
       return p2.
      }
     }
    #ppl#
     
     $PORTA=max(a,b).

    #end#

El programa anterior declara dos variables a y b, la función máximo de
dos números. Luego llama a esta función y le asigna el valor que 
retorna al puerto B del PIC. 

La gran mayoría de operaciones o sentencias en Siox termina con un '.',
los signos de agrupación son parecidos a los de C, aunque internamente
Siox es muy diferente de C, especialmente por la arquitectura del PIC.

# TIPOS DE DATOS, VARIABLES E IDENTIFICADORES

Un identificador de variable o función válido en Siox debe empezar por una letra o '_' seguido por letras, números o el caracter '_'. A excepción de las variables que empiezan por $ que son las que pasan a assembler sin ninguna modificación. Siox diferencia entre mayúsculas y minúsculas porque el Mpasm.exe lo hace. Así es diferente la variable 'W' de 'w', o 'Resultado' de 'resultado'.

Siox solo soporta un tipo de dato el byte. PIC puede trabajar con datos enteros pero emulándolos, así que tiene a su disposición el lenguaje para que les dé soporte. 

# CONSTANTES

Las constantes son enteros numéricos decimales, en lo posible entre 0 y 255.
Las constantes que se encuentren se convierten en hexadécimales para pasarse al asembler. 

# SALTOS CONDICIONALES

El salto condicional de Siox es if, su sintaxis es muy parecida a la de C aunque tiene algunas limitaciones. Por ejemplo no se pueden insertar funciones en la condición como por ejemplo:

	if(fun(x)>q){...}

Tampoco puede dejarse el 'if' sin las llaves pues generará un error gramatical:
	
	if(a>10)
	a=1.		:Esto genera un error de gramática:
		
Dentro del if puede realizarse cualquier operación que esté permitida en un bloque. La sentencia 'else' es opcional y se pone luego de cerrar la llave del 'if'.

Ejemplo:

	if(n+a<60)
	{
	  b=mult(a,4).
          a=a+b.
	}
	else {a=a+a.}

Los if´s se convierten en BTFSC, BTFSS y GOTOS probándolos con el registro STATUS. Los saltos condicionales son una gran ventaja frente al asembler pues en éste se hace muy complicado realizar sentencias condicionales en un código compacto, requiriendo varios GOTO.  
	 
# CICLOS

El único ciclo condicional en Siox es el 'while', las condiciones de este son iguales a las del if, con las mismas limitaciones. Un ejemplo de un ciclo while:
	
	while(a-b>0)
	{
	   a--.
	   b++.
	   comp(a,b,1).		 	
	}

# SALTOS INCONDICIONALES

Un salto incondicional es una creación de una etiqueta y una llamada 'goto'. El goto se traduce directamente al assembler al igual que una etiqueta (agregándole el '_' de todo identificador). Una etiqueta es su identificador seguido por '>'.  

Ejemplo:
	etq1>
	    a=1+n.
	    n=j.
	    if(a==100)
	    {goto fin.}
	    goto etq1.
	fin> 			
	
# FUNCIONES

En Siox no existen variables locales. Trate de usar la cantidad mínima de parámetros y variables locales en la declaración de funciones, pues no son temporales como en lenguajes como C. Estas consumen memoria como una variable global. 
Las variables locales pertenecen a la función pero en realidad son variables globales. Así que pueden ser llamadas desde cualquier parte del programa. Debe ser cuidadoso con tratar de nombrar una variable en una función con el mismo nombre de una global. El permitir crear variables dentro de funciones es únicamente para darle legibilidad al código fuente.
Para declarar una variable dentro de la función utilice una declaración normal luego del nombre de la función. Ejemplo:

	byte mi_func(byte a,b)
	  byte c. d. e.
	  byte noumero_error.
	{
	  if(a<b)
	  .
	  .
	  .
	}	
	
Para asignar a una variable el valor retornado de una función use:
	
	var=funcion(x,y,z).

# COMENTARIOS

Se hacen con ';' para comentarios de una sola línea. Para comentarios de más de una línea de largo utilice ':' seguido del comentario y cierre con ':'.
 
# EJEMPLO DE PROGRAMA TRADUCIDO A ASEMBLER

Programa:

    ;<<Programa_Ejemplo.ox>>
    #var#
    i.
    t.

    #fnn#
    ;Bits de conf 1=entrada 0=salida
    configurar_puerto_B(byte conf)
    {
    $W=conf.
    [	
        TRIS 	PORTB	;CONFIGURAR EL PTO B
    ]
    }
    #ppl#
    ;Programa que detecta cambios en el ;puerto B y termina luego de 10 cambios

    ;PTOB -> todos salida
    configurar_puerto_B(255). 
    t=$PORTB.
    i=10.

    while(i>0)
    {
       while($PORTB=?t)
       {	
       }		
       i--.
       t=$PORTB.
    }
    #end#
    
Assembler:

    ;<<Programa_Ejemplo.asm>>		

    Include<P16F873.INC>   
    LIST P=16F873, R=HEX
    S0__	EQU	021H
    S1__	EQU	022H
    i_	EQU	023H
    t_	EQU	024H
    conf_	EQU	025H
    ;--VARIABLES-------------------
        ORG	0
        GOTO	_PPAL
    ;--FUNCIONES-------------------
        CLRW
    configurar_puerto_B_:
        MOVF	conf_,0
        TRIS 	PORTB	;CONFIGURAR EL PTOB
        RETURN
    ;--PRINCIPAL--------------------
    _PPAL	CLRW
        MOVLW	0FFH
        MOVWF	conf_
        CALL	configurar_puerto_B_
        MOVF	PORTB,0
        MOVWF	t_
        MOVLW	0AH
        MOVWF	i_
    _WHL0:
        MOVLW	00H
        MOVWF	S1__
        MOVF	i_,0
        SUBWF	S1__,0
        BTFSC	STATUS,0
        GOTO	_ELS0
    _WHL1:
        MOVF	PORTB,0
        MOVWF	S1__
        MOVF	t_,0
        SUBWF	S1__,0
        BTFSS	STATUS,2
        GOTO	_ELS1
        GOTO	_WHL1
    _ELS1:
        DECF	i_
        MOVF	PORTB,0
        MOVWF	t_
        GOTO	_WHL0
    _ELS0:
        SLEEP
        END
    ;------------------------------
 

# ESCAPE DEL LENGUAJE

Una de las ventajas de Siox es que permite la inserción de código assembler directamente en el código fuente del programa, para hacer eso insértelo entre '[' ']' ya sea en la sección de funciones o en el bloque principal. Todo lo que esté entre éstos se pasa directamente al archivo .asm. Si desea utilizar variables, funciones o etiquetas de 'goto' externas a ese código nómbrelas con su identificador seguido con '_'. Este símbolo se agrega a todo identificador (a excepción de los que empiezan con $) para evitar conflictos con las palabras claves del assembler Mpasm, por ejemplo el identificador 'b' es una palabra clave reservada del assembler, lo que generaría un conflicto muy común si no se le distingue con '_'.

# LIBRERÍAS

## Uso de las librerías

Las librerías no se enlazan directamente a los programas, usted debe insertar en el programa las funciones que necesite. Siox provee algunas librerías para las funciones básicas del PIC, además de operaciones matemáticas y una para comunicación serial. Estas librerías sólo han sido probadas muy pocas veces así que trate de probarlas y mejorarlas.

Una función de librería se pone en la sección #fnn# del programa, algunas librerías requieren de variables, las que deben insertarse en la sección #var# del programa. 

## Base (base.oxl)

Es una librería en assembler que contiene lo que todo programa hecho en Siox debe llevar, la llamada al archivo p16f873.inc que define las variables y registros generales, y dos variables de uso privado del lenguaje. Puede editar este archivo para poner variables comunes para todos sus programas. Esta librería no debe llevar funciones ni ningún tipo de operaciones.

## Matemáticas (mat.oxl)

Si desea hacer uso de funciones matemáticas ingrese al archivo mat.oxl en la carpeta \lib y copie las funciones necesarias en su programa. No incluya funciones que no va a utilizar, recuerde que el pic16f873 es un dispositivo con memoria limitada. Si desea optimizar alguna de estas funciones hágalo en el código assembler e insértelo en su programa entre '[' ']'. 

## Estándar (est.oxl)

La librería estándar provee soporte a varias de loas operaciones del PIC que no se pueden acceder directamente por el lenguaje, estas utilizan funciones para realizar desplazamientos de bits, llamadas a macros del assembler (como BANKSEL). Para hacer uso de estas librerías es recomendable que copie en su código explícitamente las funciones que va a utilizar, pues podría estar incluyendo funciones innecesarias que le quitarían espacio en el programa compilado y ensamblado en el hexadecimal.

## Serial (serial.oxl)

La librería serial trae las funciones para la comunicación serial entre el PIC y el computador. Básicamente estas rutinas consisten en una llamada a la configuración de los puertos del PIC para la salida y una función de retardo para la temporización del envío de datos.

La librería actual da soporte a comunicación a 1200 baudios, usted puede cambiar esta velocidad en la sección del retardo, dándole valores y probándolos. En el PIC el pin de transmisión es el bit 7 del puerto B y el de recepción es el bit 6.

# INSTALACIÓN Y USO

Para instalar sioxc:

1. Cierre Mplab si lo está usando.
2. Descomprima el archivo donde se encuentra sioxc si esta comprimido o copie todos los archivos si no lo está en la carpeta principal del Mplab. No olvide incluir la carpeta \lib. 
3. Ingrese a Mplab y selección crear un nuevo proyecto, dele un nombre. En la ventana 'Edit Project' en 'Languaje Tool Suite' despliegue la lista y busque Siox. Seleccione el archivo 'hex' e Ingrese a 'Node Properties' y de OK.
4. Adicione un nodo con 'Add Node', usando un archivo.ox, y de OK.
5. Abra el archivo que va a utilizar y edítelo usando el lenguaje Siox.
6. IMPORTANTE: antes de compilar debe instalar el compilador, haga esto por el menú 'Project' y seleccione 'Install Languaje Tool'. En la línea 'Executable' busque el archivo SIOX.EXE (no use sioxc.exe aquí) y seleccione la opción Windowed y de OK. Este paso solo debe hacerlo una vez, para la próxima vez que cree un proyecto con el lenguaje Siox, Mplab seleccionará el compilador.
7. Para crear el .hex, que es el archivo que se pasará al PIC compile normalmente con 'Build' o 'Make' del menú project. Espere los resultados. El programa manejador siox.exe abrirá una consola para compilar, donde saldrán los posibles mensajes de error. Para continuar cierre esa ventana.
8. Usted podrá ahora, si no hubo errores abrir el archivo .asm. Trate de no hacer modificaciones directamente en ese archivo sin hacer copias pues si vuelve a compilar con sioxc se sobrescribirá.

Para el uso normal luego de instalarlo repita los pasos 3,4,5,7 y 8.        
Recuerde que el proceso de compilación es diferente al de ensamblaje, a pesar de que el programa se compile correctamente, al momento de ensamblarlo pueden ocurrir errores. El ensamblaje lo hace el mpasm.exe.
Si desea usar el compilador fuera de la IDE de Mplab ignore el ejecutable siox.exe y utilice sioxc.exe en la línea de comandos de DOS seguido por el nombre del archivo donde creó el programa. Se generará, si no se presentan errores un archivo .asm que usted puede compilar con mpasm.exe o mpasmwin.exe.

# PARA MAS INFORMACIÓN
Escríbame para sugerencias o si tiene algún
problema con algún programa envíe el código fuente, el archivo 
su_programa.err y los mensajes de error del compilador (use el
modificador de redirección  '> archivo.txt' en DOS después de la línea
de comando del compilador para guardar los errores en ese archivo).

Copyright 2001 Andres Agudelo-Toro
Universidad EAFIT
